module Loans
  class AdjustRestructuredLoans
    def initialize(loan:, user:, date_paid:)
      @loan       = loan
      @user       = user
      @date_paid  = date_paid
      @particular = @loan.data["accounting_entry"]["particular"]
    end

    def execute!
      @loan.data["restructured_loans"].each do |h|
        loan = Loan.find(h["id"])

        principal_balance = h["principal_balance"].to_f.round(2)
        interest_balance  = h["interest_balance"].to_f.round(2)
        total_balance     = h["total_balance"].to_f.round(2)

        # Perform payment transactions
        loan_payment = {
          loan_id: loan.id,
          record_type: "LOAN_PAYMENT",
          loan_product: h["loan_product"],
          amount: total_balance,
          enabled: true
        }

        config = {
          loan_payment: loan_payment,
          date_paid: @date_paid,
          user: @user,
          particular: @particular,
          loan: loan
        }

        ::Billings::ApproveLoanPaymentHash.new(config: config).execute!
      end
    end
  end
end
