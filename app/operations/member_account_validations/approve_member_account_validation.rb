module MemberAccountValidations
  class ApproveMemberAccountValidation
    def initialize(config:)
      @config                    = config

      @member_account_validation = @config[:member_account_validation]
      @user                      = @config[:user]
      @interest_amount           = @member_account_validation.member_account_validation_records.sum(:interest)
      
      @data = @member_account_validation.try(:data).try(:with_indifferent_access)

      @data_accounting_entry  = @member_account_validation.accounting_entry
      
      @c_working_date               = Date.today
    end

    def execute!
      # if @interest_amount > 0
      #   @voucher.save!
      #   @voucher = Accounting::ApproveVoucher.new(voucher: @voucher, user: @user).execute!
      # end

      post_accounting_entry!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @member_account_validation.update!(
        status: "approved",
        reference_number: @accounting_entry.reference_number,
        updated_at: @c_working_date,
        approved_by: @user,
        date_approved: @c_working_date,
        data: @data
      )
       
      create_rf_member_deposits!

      # COMMMENT OUT
      # create_lif_member_deposits!

      if Settings.activate_microloans
        withdraw_lif_and_rf_deposit_to_savings!
      elsif Settings.activate_micromember
        withdraw_lif_and_rf_deposit_to_zero_account!
      end

      approved_member_account_validation_record_status!     
    
      @member_account_validation
    end

    private

    def approved_member_account_validation_record_status!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|
        member_account_validation_record.update!(
          status: "approved",
          transaction_number: member_account_validation_record.id.to_s.rjust(6, "0")
          )
        
        if Settings.activate_microloans
          if member_account_validation_record.member_classification == "EXIT AGE (GK)"
            member_account_validation_record.member.update!(
              member_status: "resigned",
              member_date_resigned: member_account_validation_record.resignation_date,
              member_type: "GK"
            )
          elsif member_account_validation_record.member_classification == "DECEASED"
            member_account_validation_record.member.update!(
              member_status: "resigned",
              member_date_resigned: member_account_validation_record.resignation_date,
              is_deceased: true
            )
          else
            member_account_validation_record.member.update!(
              member_status: "resigned",
              member_date_resigned: member_account_validation_record.resignation_date
            )
          end
        elsif Settings.activate_micromember
          member_account_validation_record.member.update!(
            status: "resigned",
            member_status: "resigned",
            member_date_resigned: member_account_validation_record.resignation_date,
            date_resigned: member_account_validation_record.resignation_date,
            resignation_reason: "Resigned to MFI"
          )
        end  
      end
    end

    def create_rf_member_deposits!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|

        config  = {
          date_paid: @c_working_date,
          member_account_validation: member_account_validation_record,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::MemberAccountValidations::ApproveRfMemberDeposit.new(
          config: config
        ).execute!
      end
    end

    def create_lif_member_deposits!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|
          
        member          = member_account_validation_record.member
        member_type    = memberType.where(code: "LIF").first
        member_account = memberAccount.where(member_id: member.id, member_type_id: member_type.id).first
        member_account_transaction = MemberAccountTransaction.create!(
                                          amount: member_account_validation_record.equity_interest,
                                          transacted_at: @c_working_date,
                                          created_at: @c_working_date,
                                          particular: "Interest of Equity per week",
                                          transaction_type: "interest",
                                          voucher_reference_number: @voucher.reference_number,
                                          member_account: member_account,
                                          for_resignation: true
                                        )
        member_account_transaction.approve!(@user.full_name)
      end
    end

    def withdraw_lif_and_rf_deposit_to_zero_account!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|
          
        member          = member_account_validation_record.member
        member.member_accounts.each do |member_account|
          
          balance = member_account.balance
          member_account_transaction = MemberAccountTransaction.create!(
                                            amount: balance,
                                            transacted_at: @c_working_date,
                                            created_at: @c_working_date,
                                            particular: "Withdrawal of #{member_account.member_type}",
                                            transaction_type: "withdraw",
                                            voucher_reference_number: @voucher.reference_number,
                                            member_account: member_account,
                                            for_resignation: true
                                          )
          member_account_transaction.approve!(@user.full_name)
        end
      end
    end

    def withdraw_lif_and_rf_deposit_to_savings!
      @member_account_validation.member_account_validation_records.each do |member_account_validation_record|
          
       config  = {
        date_paid: @c_working_date,
        member_account_validation: member_account_validation_record,
        user: @user,
        particular: @data_accounting_entry[:particular]
        }

        member          = member_account_validation_record.member
        member.member_accounts.each do |member_account|
          
          balance = member_account.balance
          member_account_transaction = memberAccountTransaction.create!(
                                            amount: balance,
                                            transacted_at: @c_working_date,
                                            created_at: @c_working_date,
                                            particular: "Withdrawal of #{member_account.member_type}",
                                            transaction_type: "withdraw",
                                            voucher_reference_number: @voucher.reference_number,
                                            member_account: member_account,
                                            for_resignation: true
                                          )
          member_account_transaction.approve!(@user.full_name)
        end

        # half_adv_lif = member_account_validation_record.try(:advance_lif) / 2 
        due_to_members = (member_account_validation_record.try(:interest) + member_account_validation_record.try(:rf) + member_account_validation_record.try(:advance_rf) + member_account_validation_record.try(:lif_50_percent) + member_account_validation_record.try(:advance_lif))
        
        if member_account_validation_record.member_classification == "EXIT AGE (GK)"
          savings_type    = SavingsType.where(code: "GK").first

          if savings_type
            savings_account = SavingsAccount.where(member_id: member.id, savings_type_id: savings_type.id).first
            savings_account_transaction = SavingsAccountTransaction.create!(
                                              amount: due_to_members,
                                              transacted_at: @c_working_date,
                                              created_at: @c_working_date,
                                              particular: "Deposit of savings",
                                              transaction_type: "deposit",
                                              voucher_reference_number: @voucher.reference_number,
                                              savings_account: savings_account,
                                              for_resignation: true
                                            )
          end
        else
          savings_type    = SavingsType.where(code: "K-IMPOK").first

          if savings_type
            savings_account = SavingsAccount.where(member_id: member.id, savings_type_id: savings_type.id).first
            savings_account_transaction = SavingsAccountTransaction.create!(
                                              amount: due_to_members,
                                              transacted_at: @c_working_date,
                                              created_at: @c_working_date,
                                              particular: "Deposit of savings",
                                              transaction_type: "deposit",
                                              voucher_reference_number: @voucher.reference_number,
                                              savings_account: savings_account,
                                              for_resignation: true
                                            )
          end
        end

        savings_account_transaction.approve!(@user.full_name)
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
