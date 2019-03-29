module Loans
  class Approve
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]

      @member           = @loan.member
      @loan_product     = @loan.loan_product
      @num_installments = @loan.num_installments
      @term             = @loan.term
      
      @current_date = Date.today

      if Settings.current_date.present?
        @current_date = Settings.current_date.to_date
      end
      
      @member       = @loan.member
      @member_data  = @member.data.with_indifferent_access

      # Main settings for this loan product
      @settings = nil

      @transaction_type = "deposit"
      @date_paid        = @current_date

      Settings.loan_products.each do |s|
        if s.loan_product_id == @loan_product.id
          @settings = s
        end
      end

      if @settings.blank?
        raise "Settings not foud for loan product #{@loan_product.id}: #{@loan_product.name}. Please check production.yml"
      end

      # Setup loan cycle
      @loan_cycles            = @member_data[:loan_cycles] || []
      @entry_point_loan_cycle = @member_data[:entry_point_loan_cycle] || 0
    end

    def execute!
      post_accounting_entry!

      perform_deposits!

      if @loan_cycles.blank?
        @loan_cycles  = [
          {
            loan_product_id: @loan_product.id,
            cycle: 1
          }
        ]
      else
        if @loan_product.is_entry_point
          @entry_point_loan_cycle = @entry_point_loan_cycle + 1
        end

        found = false
        @loan_cycles.each_with_index do |c, i|
          if c[:loan_product_id] == @loan_product.id
            @loan_cycles[i][:cycle] = c[:cycle] + 1
            found = true
          end
        end

        if !found
          @loan.cycle = 1
          @loan_cycles << {
            loan_product_id: @loan_product.id,
            cycle: @loan.cycle
          }
        end
      end

      # Updat member data
      @member_data[:loan_cycles]            = @loan_cycles
      @member_data[:entry_point_loan_cycle] = @entry_point_loan_cycle
      @member.update!(data: @member_data)

      @loan.update!(
        status: "active",
        date_approved: @current_date
      )

      @loan
    end

    private

    def perform_deposits!
      @settings.deductions.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type

        if s_deduction.name == "KMBA Membership Fee"
          @date_paid = @loan.date_released
        end 


        if deduction_type == "membership_fee"
          membership_payment_record = MembershipPaymentRecord.paid.where(
                                        membership_type: s_deduction.membership_type,
                                        member_id: @loan.member.id
                                      ).first


          if membership_payment_record.blank?
            MembershipPaymentRecord.create!(
              member: @loan.member,
              membership_type: s_deduction.membership_type,
              membership_name: s_deduction.meta.membership_name,
              amount: s_deduction.amount,
              status: "paid",
              date_paid: @date_paid
            )

            # Check if we already have loans (for old accounts transferred form 1.0)
            if @member.loans.active_or_paid.count > 0
              @member_data[:recognition_date] = @member.loans.active_or_paid.order("date_approved ASC").first.date_approved
            else
              @member_data[:recognition_date] = @date_paid
            end
          end

          @member.update!(insurance_status: "inforce")
        elsif deduction_type == "deposit"
          if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards"
            offset          = s_deduction.meta.offset
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            name            = accounting_code.name
            code            = accounting_code.code
            amount          = 0.00
            val             = s_deduction.meta.value

            multiplier  = @num_installments

            loan_cycle  = @loan_cycles.select{ |c| c[:cycle] >= 1 and c[:loan_product_id] == @loan_product.id }.first
            if loan_cycle.present?
            #if @member.loans.paid.where(loan_product_id: @loan_product.id).count >= 1
              if @term == "weekly"
              elsif @term == "monthly"
                multiplier  = (multiplier * 4.3333333).ceil.to_i
              elsif @term == "semi-monthly"
                # weird unique rule for 12 semi-monthly
                if @num_installments ==  12
                  multiplier  = 12.5 * 2
                elsif @num_installments == 6
                  multiplier  = 15
                else
                  multiplier  = multiplier * 2
                end
              else
                raise "Invalid term #{@term}"
              end

              amount  = val * (multiplier + offset)
            else
              amount  = val
            end

            #### DEPOSIT TRANSACTION ####
            if amount > 0
              member_account  = MemberAccount.where(
                                  member_id: @member.id,
                                  account_type: s_deduction.meta.account_type,
                                  account_subtype: s_deduction.meta.account_subtype
                                ).first

              account_transaction = AccountTransaction.new(
                                      subsidiary_id: member_account.id,
                                      subsidiary_type: "MemberAccount",
                                      amount: amount,
                                      transaction_type: @transaction_type,
                                      transacted_at: @date_paid,
                                      status: "approved",
                                      data: {
                                        is_withdraw_payment: false,
                                        is_fund_transfer: false,
                                        is_interest: false,
                                        is_adjustment: false,
                                        is_for_exit_age: false,
                                        is_for_loan_payments: false,
                                        accounting_entry_reference_number: nil,
                                        beginning_balance: 0.00,
                                        ending_balance: 0.00
                                      }
                                    )

              # Compute beginning and ending balance
              account_transaction.data[:beginning_balance]  = member_account.balance.round(2)
              account_transaction.data[:ending_balance]     = (member_account.balance + amount).round(2)

              # Update account balance
              new_balance = (member_account.balance + amount).round(2)
              member_account.update!(
                balance: new_balance
              )

              account_transaction.save!
            end 
            #### DEPOSIT TRANSACTION

          end
        end
      end
    end

    def post_accounting_entry!
      accounting_entry_data = @loan.data.with_indifferent_access[:accounting_entry]

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: {
                              id: nil,
                              accounting_entry_data: accounting_entry_data,
                              user: @user
                            }
                          ).execute!

      accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                            config: {
                              accounting_entry: accounting_entry,
                              user: @user
                            }
                          ).execute!

      # Update reference number
      data  = @loan.data.with_indifferent_access
      data[:accounting_entry][:reference_number] = accounting_entry.reference_number

      @loan.update!(
        data: data
      )
    end
  end
end
