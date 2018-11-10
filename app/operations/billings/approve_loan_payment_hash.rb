module Billings
  class ApproveLoanPaymentHash
    def initialize(config:)
      @config       = config
      @loan_payment = @config[:loan_payment]
      @date_paid    = @config[:date_paid]
      @user         = @config[:user]
      @particular   = @config[:particular]
      @amount       = @loan_payment[:amount].try(:to_f).round(2)
      @loan         = Loan.find(@loan_payment[:loan_id])

      @account_transaction  = AccountTransaction.new(
                                subsidiary_id: @loan.id,
                                subsidiary_type: "Loan",
                                transaction_type: "loan_payment",
                                transacted_at: @date_paid,
                                status: "approved"
                              )

      @data = {
        amort_entries: [],
        total_interest_paid: 0.00,
        total_principal_paid: 0.00,
        amount_due: 0.00,
        particular: @particular,
        approved_by: @user.full_name
      }
    end

    def execute!
      payment_stats = ::Loans::FetchPaymentStats.new(
                        config: {
                          loan: @loan,
                          amount: @amount,
                          date_paid: @date_paid
                        }
                      ).execute!
      
      @data[:total_principal_paid]  = payment_stats[:principal_paid]
      @data[:total_interest_paid]   = payment_stats[:interest_paid]
      @data[:amount_due]            = payment_stats[:amount_due]
      @data[:amort_entries]         = payment_stats[:amort_entries]

      @account_transaction.data = @data
      @account_transaction.save!

      # Update amortization entries
      @data[:amort_entries].each do |ae|
        amort = AmortizationScheduleEntry.find(ae[:id])

        principal_paid  = amort.principal_paid
        interest_paid   = amort.interest_paid

        principal_balance = amort.principal_balance
        interest_balance  = amort.interest_balance

        is_paid = amort.is_paid

        data  = amort.data.try(:with_indifferent_access)

        if data.blank?
          data  = {
            payments: []
          }
        end

        data[:payments] << {
          payment_id: @account_transaction.id,
          payment_date: @date_paid,
          principal_paid: ae[:principal_paid],
          interest_paid: ae[:interest_paid]
        }

        # Compute new principal_paid, interest_paid, principal_balance, interest_balance
        principal_paid  += ae[:principal_paid].try(:to_f).round(2)
        interest_paid   += ae[:interest_paid].try(:to_f).round(2)

        principal_balance = (amort.principal - principal_paid).round(2)
        interest_balance  = (amort.interest - interest_paid).round(2)

        # Check if we're paid
        if principal_balance == 0.00 && interest_balance == 0.00
          is_paid = true
        end

        # Update this amort
        amort.principal_paid    = principal_paid
        amort.interest_paid     = interest_paid
        amort.principal_balance = principal_balance
        amort.interest_balance  = interest_balance
        amort.is_paid           = is_paid
        amort.data              = data

        amort.save!
      end

      # Update loan balances
      updated_amort         = AmortizationScheduleEntry.where(loan_id: @loan.id)
      @loan.principal_paid  = updated_amort.sum(:principal_paid).round(2)
      @loan.interest_paid   = updated_amort.sum(:interest_paid).round(2)

      @loan.principal_balance = (@loan.principal - @loan.principal_paid).round(2)
      @loan.interest_balance  = (@loan.interest - @loan.interest_paid).round(2)

      @loan.save!

      # Close loan if completed
      if @loan.principal_balance == 0.00 and @loan.interest_balance == 0.00
        @loan.update!(
          date_completed: @date_paid,
          status: "paid"
        )
      end

      @account_transaction
    end
  end
end
