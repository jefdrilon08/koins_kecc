module Loans
  class ApproveLoanPayment
    def initialize(loan:, account_transaction:, approved_by:, mark_past_due: true)
      @loan                 = loan
      @account_transaction  = account_transaction
      @mark_past_due        = mark_past_due
      @approved_by          = approved_by
    end

    def execute!
      approve_loan_payment!

      at_data = @account_transaction.data

      if at_data.blank?
        at_data = {}
      end

      at_data["approved_by"]  = @approved_by

      at_data["approved_by"]  = @approved_by
      @account_transaction.update!(
        status: "approved",
        data: at_data
      )

      @unpaid_ase  = AmortizationScheduleEntry.unpaid.where(
                      "loan_id = ? AND due_date <= ?", 
                      @loan.id, 
                      @account_transaction.transacted_at
                    ).order("due_date ASC")

      # Mark as past due
      if @mark_past_due == true
        @unpaid_ase.each do |ase|
          data      = ase.data
          past_due  = []

          if !data
            data = {}
          elsif data["past_due"]
            past_due  = data["past_due"]
          end

          past_due << {
            transacted_at: @account_transaction.transacted_at,
            principal_balance: ase.principal_balance,
            interest_balance: ase.interest_balance
          }

          data["past_due"] = past_due

          ase.update!(
            is_past_due: true,
            data: data
          )
        end
      end
    end

    private

    def approve_loan_payment!
      remaining_balance = (@loan.amortization_schedule_entries.unpaid.sum(:principal_balance) + @loan.amortization_schedule_entries.unpaid.sum(:interest_balance))

      if @account_transaction.amount > remaining_balance.round(2)
        raise "Invalid amount #{@account_transaction.amount} for loan #{@loan} (#{@loan.id}). Remaining balance: #{remaining_balance}. Payment ID: #{@account_transaction.id}"
      end
     
      total_interest_paid   = @account_transaction.data["total_interest_paid"].to_f
      total_principal_paid  = @account_transaction.data["total_principal_paid"].to_f

      @account_transaction.data["amort_entries"].each do |amort_entry|
        amortization_schedule_entry = AmortizationScheduleEntry.find(amort_entry["id"])
        principal_paid    = amortization_schedule_entry.principal_paid + amort_entry["principal_paid"].to_f
        interest_paid     = amortization_schedule_entry.interest_paid + amort_entry["interest_paid"].to_f
        principal_balance = amortization_schedule_entry.principal_balance - amort_entry["principal_paid"].to_f
        interest_balance  = amortization_schedule_entry.interest_balance  - amort_entry["interest_paid"].to_f

        amortization_schedule_entry.update!(
          principal_paid: principal_paid,
          interest_paid: interest_paid,
          principal_balance: principal_balance,
          interest_balance: interest_balance,
        )
      end

      principal_paid    = @loan.principal_paid
      interest_paid     = @loan.interest_paid
      principal_balance = @loan.principal_balance
      interest_balance  = @loan.interest_balance

      @loan.update!(
        principal_paid: (principal_paid + total_principal_paid).round(2),
        interest_paid: (interest_paid + total_interest_paid).round(2),
        principal_balance: (principal_balance - total_principal_paid).round(2),
        interest_balance: (interest_balance - total_interest_paid).round(2)
      )

      if @loan.active? and @loan.principal_balance <= 0.00 and @loan.interest_balance <= 0.00
        @loan.update!(
          date_completed: @account_transaction.transacted_at,
          status: "paid"
        )
      end
    end
  end
end
