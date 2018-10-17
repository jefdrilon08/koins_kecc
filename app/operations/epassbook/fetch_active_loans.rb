module Epassbook
  class FetchActiveLoans
    def initialize(member:)
      @member       = member
      @active_loans = @member.loans.where(status: "active")

      @loans          = []
      @total_balance  = 0.00
    end

    def execute!

      @active_loans.each do |o|
        last_payment  = AccountTransaction.approved_loan_payments.where(
                          subsidiary_id: o.id,
                          subsidiary_type: "Loan"
                        ).order("transacted_at ASC").last

        next_payment  = o.amortization_schedule_entries.unpaid.first

        @loans << {
          id: o.id,
          principal: o.principal,
          interest: o.interest,
          total_dues: o.total_dues,
          total_balance: o.total_balance,
          total_paid: o.total_paid,
          loan_product: o.loan_product.to_s,
          pn_number: o.pn_number,
          next_payment_amount: next_payment.total_balance,
          next_payment_date: next_payment.due_date.strftime("%B %d, %Y"),
          last_payment_amount: last_payment.try(:amount) || 0.00,
          last_payment_date: last_payment.present? ? last_payment.transacted_at.strftime("%B %d, %Y") : "N/A"
        }

        @total_balance += o.total_balance
      end

      @data = {
        loans: @loans,
        total_balance: @total_balance
      }

      @data
    end
  end
end
