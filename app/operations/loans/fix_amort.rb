module Loans
  class FixAmort
    def initialize(loan:)
      @loan           = loan

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
        status: 'active',
        first_date_of_payment: @amort_entries.first.due_date
      )

      # Reset amortization
      @amort_entries.each do |ase|
        ase.update!(
          principal_paid: 0.00,
          interest_paid: 0.00,
          principal_balance: ase.principal,
          interest_balance: ase.interest,
          data: {
            payments: []
          },
          is_paid: nil
        )
      end

      # Go through each loan payment and assign amort proponents
      @loan_payments.each do |o|
        amort_entries = o.data.with_indifferent_access[:amort_entries]

        amort_entries.each do |a|
          amort = AmortizationScheduleEntry.find(a[:id])

          principal_paid    = amort.principal_paid
          interest_paid     = amort.interest_paid
          principal_balance = amort.principal_balance
          interest_balance  = amort.interest_balance
          
          data  = amort.data.with_indifferent_access

          principal_paid += a[:principal_paid].to_f.round(2)
          interest_paid += a[:interest_paid].to_f.round(2)

          principal_balance -= a[:principal_paid].to_f.round(2)
          interest_balance  -= a[:interest_paid].to_f.round(2)

          is_paid = nil

          if principal_balance == 0.00 and interest_balance == 0.00
            is_paid = true
          end

          data[:payments] << {
            payment_id: o.id,
            payment_date: o.transacted_at,
            principal_paid: a[:principal_paid].to_f.round(2),
            interest_paid: a[:interest_paid].to_f.round(2)
          }

          amort.update!(
            principal_paid: principal_paid,
            interest_paid: interest_paid,
            principal_balance: principal_balance,
            interest_balance: interest_balance,
            data: data,
            is_paid: is_paid
          )
        end
      end

      # Update balances for loan
      @loan = Loan.find(@loan.id)

      principal_paid  = @loan_payments.sum("CAST(data->>'total_principal_paid' AS decimal)").round(2)
      interest_paid   = @loan_payments.sum("CAST(data->>'total_interest_paid' AS decimal)").round(2)

      principal_balance = (@loan.principal - principal_paid).round(2)
      interest_balance  = (@loan.interest - interest_paid).round(2)

      @loan.update!(
        principal_paid: principal_paid,
        interest_paid: interest_paid,
        principal_balance: principal_balance,
        interest_balance: interest_balance
      )

      if @loan.active? and @loan.principal_balance <= 0.00 and @loan.interest_balance <= 0.00
        @loan.update!(
          date_completed: @loan_payments.last.transacted_at,
          status: "paid"
        )
      end

      @loan
    end
  end
end
