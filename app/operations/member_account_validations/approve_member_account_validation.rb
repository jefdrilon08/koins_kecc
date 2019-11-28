module MemberAccountValidations
  class ApproveMemberAccountValidation
    def initialize(config:)
      @config                    = config

      @member_account_validation = @config[:member_account_validation]
      @user                      = @config[:user]
      @interest_amount           = @member_account_validation.member_account_validation_records.sum(:interest)
      @branch                    = @member_account_validation.branch
      @data                      = @member_account_validation.try(:data).try(:with_indifferent_access)

      @data_accounting_entry     = @data[:accounting_entry]
      
      @c_working_date            = ::Utils::GetCurrentDate.new(
                                    config: {
                                      branch: @branch
                                    }
                                  ).execute!
    end

    def execute!
      post_accounting_entry!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by
       
      create_rf_member_deposits!

      # COMMMENT OUT
      create_equity_interest_deposits!

      if Settings.activate_microloans
        withdraw_lif_and_rf_deposit_to_savings!
      elsif Settings.activate_microinsurance
        withdraw_lif_and_rf_deposit_to_zero_out_account!
      end

      approved_member_account_validation_record_status!     
    
      @member_account_validation.update!(
        status: "approved",
        reference_number: @accounting_entry.reference_number,
        updated_at: @c_working_date,
        approved_by: @user,
        date_approved: @c_working_date,
        data: @data
      )

      @member_account_validation
    end

    private

    def approved_member_account_validation_record_status!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|

        member_account_validation_record.update!(
          status: "approved",
          transaction_number: member_account_validation_record.id.to_s.rjust(6, "0")
          )

        member_data = member_account_validation_record.member.data.with_indifferent_access

        member_data[:insurance_resignation] = {}
        
        if Settings.activate_microloans
          if member_account_validation_record.member_classification == "EXIT AGE (GK)"
            member_data[:insurance_resignation] = {
                                                  date_resigned: member_account_validation_record.resignation_date,
                                                  resignation_reason: "GK"
                                                  }
            
            member_account_validation_record.member.update!(
              insurance_status: "resigned",
              insurance_date_resigned: member_account_validation_record.resignation_date,
              member_type: "GK",
              data: member_data
            )
          elsif member_account_validation_record.member_classification == "DECEASED"
            member_data[:insurance_resignation] = {
                                                  date_resigned: member_account_validation_record.resignation_date,
                                                  resignation_reason: "Deceased",
                                                  is_deceased: true
                                                  }

            member_account_validation_record.member.update!(
              insurance_status: "resigned",
              insurance_date_resigned: member_account_validation_record.resignation_date,
              data: member_data
            )
          else
            member_data[:insurance_resignation] = {
                                                  date_resigned: member_account_validation_record.resignation_date,
                                                  resignation_reason: "resigned"
                                                  }

            member_account_validation_record.member.update!(
              insurance_status: "resigned",
              insurance_date_resigned: member_account_validation_record.resignation_date,
              data: member_data
            )
          end
        elsif Settings.activate_microinsurance
           member_data[:insurance_resignation] = {
                                                  date_resigned: @c_working_date,
                                                  resignation_reason: "Resigned to MFI"
                                                  }

          member_account_validation_record.member.update!(
            status: "resigned",
            insurance_status: "resigned",
            date_resigned: member_account_validation_record.resignation_date,
            data: member_data,
            insurance_date_resigned: member_account_validation_record.resignation_date
          )
        end  
      end
    end

    def create_rf_member_deposits!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|
        interest = member_account_validation_record.interest

        config  = {
          amount: interest, 
          date_paid: @c_working_date,
          member_account_validation_record: member_account_validation_record,
          user: @user,
          accounting_entry_reference_number: @data_accounting_entry[:reference_number]
        }

        if interest > 0
          ::MemberAccountValidations::ApproveRfMemberDeposit.new(
            config: config
          ).execute!
        end
      end
    end

    def create_equity_interest_deposits!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|
          
        config  = {
          date_paid: @c_working_date,
          member_account_validation_record: member_account_validation_record,
          user: @user,
          accounting_entry_reference_number: @data_accounting_entry[:reference_number]
        }

        ::MemberAccountValidations::ApproveEquityInterestDeposit.new(
          config: config
        ).execute!
      end
    end

    def withdraw_lif_and_rf_deposit_to_zero_out_account!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|   
        member          = member_account_validation_record.member
        member.member_accounts.each do |member_account|

          if member_account.account_subtype == 'Life Insurance Fund' || member_account.account_subtype == 'Retirement Fund'
            config  = {
              date_paid: @c_working_date,
              member: member,
              user: @user,
              balance: member_account.balance,
              member_account: member_account,
              accounting_entry_reference_number: @data_accounting_entry[:reference_number]
              }

            ::MemberAccountValidations::ApproveWithdrawLifAndRfDepositToZeroOutAccount.new(
              config: config
            ).execute!
          end
        end
      end
    end

    def withdraw_lif_and_rf_deposit_to_savings!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|
        member          = member_account_validation_record.member
        member.member_accounts.each do |member_account|

          if member_account.account_subtype == 'Life Insurance Fund' || member_account.account_subtype == 'Retirement Fund'
            config  = {
              date_paid: @c_working_date,
              member: member,
              user: @user,
              balance: member_account.balance,
              member_account: member_account,
              accounting_entry_reference_number: @data_accounting_entry[:reference_number]
              }

            ::MemberAccountValidations::ApproveWithdrawLifAndRf.new(
              config: config
            ).execute!
          end
        end

        # half_adv_lif = member_account_validation_record.try(:advance_lif) / 2 
        due_to_members = (member_account_validation_record.try(:equity_interest) + member_account_validation_record.try(:interest) + member_account_validation_record.try(:rf) + member_account_validation_record.try(:advance_rf) + member_account_validation_record.try(:lif_50_percent) + member_account_validation_record.try(:advance_lif))
        
        if member_account_validation_record.member_classification == "EXIT AGE (GK)"
          savings_account    = MemberAccount.where(account_type: "SAVINGS", account_subtype: "Golden K", member_id: member.id).first

          config  = {
            date_paid: @c_working_date,
            member_account: savings_account,
            user: @user,
            amount: due_to_members,
            accounting_entry_reference_number: @data_accounting_entry[:reference_number]
            }

            ::MemberAccountValidations::ApproveDepositToSavings.new(
              config: config
            ).execute!
        else
          savings_account    = MemberAccount.where(account_type: "SAVINGS", account_subtype: "K-IMPOK", member_id: member.id).first

          config  = {
            date_paid: @c_working_date,
            member_account: savings_account,
            user: @user,
            amount: due_to_members,
            accounting_entry_reference_number: @data_accounting_entry[:reference_number]
            }

          ::MemberAccountValidations::ApproveDepositToSavings.new(
                  config: config
            ).execute!
        end
      end
    end

    def post_accounting_entry!
      # Create new accounting entry
      config  = {
        accounting_entry_data: @data_accounting_entry.with_indifferent_access,
        user: @user
      }

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: config
                          ).execute!

      # Post to books
      config  = {
        accounting_entry: accounting_entry,
        user: @user
      }

      @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                            config: config
                          ).execute!

      @accounting_entry
    end
  end
end
