module Loans
  class Reage
    def initialize(loan:, approved_by:)
      @loan           = loan
      @approved_by    = approved_by

      @loan_payments  = AccountTransaction.approved_loan_payments.where(
                          subsidiary_id: @loan.id,
                          subsidiary_type: 'Loan'
                        )

      @amort_entries  = AmortizationScheduleEntry.where(
                          loan_id: @loan.id
                        ).order("due_date ASC")
    end

    def execute!
      # Clear due amount for loan
      @loan.update!(
        principal_paid: 0.00,
        interest_paid: 0.00,
        interest_balance: @loan.interest,
        principal_balance: @loan.principal,
        status: 'active'
      )

      # Reset amortization
      @amort_entries.each do |ase|
        ase.update!(
          principal_paid: 0.00,
          interest_paid: 0.00,
          principal_balance: ase.principal,
          interest_balance: ase.interest,
          data: {},
          is_paid: nil
        )
      end

      # Recalibrate
      @loan_payments.each do |loan_payment|
        payment_config  = {
          loan: @loan,
          amount: loan_payment.amount.to_f,
          transacted_at: loan_payment.transacted_at,
          persist: false,
          particular: ""
        }

        temp  = ::Loans::CreateNewPayment.new(
                  config: payment_config
                ).execute!

        data = loan_payment.data

        data["amort_entries"]         = temp.data["amort_entries"]
        data["total_interest_paid"]   = temp.data["total_interest_paid"]
        data["total_principal_paid"]  = temp.data["total_principal_paid"]
        data["amount_due"]            = temp.data["amount_due"]
        data["particular"]            = temp.data["particular"]

        loan_payment.update!(
          status: 'pending',
          data: data
        )

        loan_payment  = ::Loans::ApproveLoanPayment.new(
                          loan: @loan,
                          account_transaction: loan_payment,
                          approved_by: @approved_by,
                          mark_past_due: false
                        ).execute!
      end

      @loan_payments  = AccountTransaction.approved_loan_payments.where(
                          subsidiary_id: @loan.id
                        ).order("transacted_at ASC")

      @amort_entries  = AmortizationScheduleEntry.where(
                          loan_id: @loan.id
                        ).order("due_date ASC")

      # Rehash to amort
      rehash_amort!

      @loan
    end

    def rehash_amort!
      @amort_entries.each do |ase|
        data              = ase.data  
        data["payments"]  = []

        @loan_payments.each do |loan_payment|
          if loan_payment.data["amort_entries"].present?
            loan_payment.data["amort_entries"].each do |amort_data|
              if amort_data["id"] == ase.id && amort_data["due_date"].to_date == ase.due_date.to_date
                data["payments"] << {
                  payment_id: loan_payment.id,
                  payment_date: loan_payment.transacted_at,
                  principal_paid: amort_data["principal_paid"],
                  interest_paid: amort_data["interest_paid"]
                }
              end
            end
          end
        end

        ase.update!(data: data)
      end
    end
  end
end
