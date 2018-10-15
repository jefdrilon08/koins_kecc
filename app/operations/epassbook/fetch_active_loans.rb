module Epassbook
  class FetchActiveLoans
    def initialize(member:)
      @member       = member
      @active_loans = @member.loans.where(status: "active")

      @loans = []

      @active_loans.each do |o|
        last_payment  = AccountTransaction.approved_loan_payments.where(
                          subsidiary_id: o.id,
                          subsidiary_type: "Loan"
                        ).order("transacted_at ASC").last
        @loans << {
          id: o.id,
          principal: o.principal,
          interest: o.interest,
          total_dues: o.total_dues,
          total_balance: o.total_balance,
          total_paid: o.total_paid,
          loan_product: o.loan_product.to_s,
          pn_number: o.pn_number,
          last_payment_amount: last_payment.try(:amount) || 0.00,
          last_payment_date: last_payment.present? ? last_payment.transacted_at.strftime("%B %d, %Y") : "N/A"
        }
      end
    end

    def execute!
      @data = {
        loans: @loans
      }

      @data
    end
  end
end
