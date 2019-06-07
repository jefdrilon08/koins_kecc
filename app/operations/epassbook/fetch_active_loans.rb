module Epassbook
  class FetchActiveLoans
    include ActionView::Helpers::NumberHelper

    def initialize(member:)
      @member       = member
      @active_loans = @member.loans.where(status: "active")

      @loans          = []
      @total_balance  = 0.00
      @total_loan     = 0.00
      @total_interest = 0.00
      @total_amount   = 0.00
      @total_paid     = 0.00
      @next_payment_total_amount = 0.00
      @total_past_due = 0.00

    end

    def execute!

      @active_loans.each do |o|
        last_payment  = AccountTransaction.approved_loan_payments.where(
                          subsidiary_id: o.id,
                          subsidiary_type: "Loan"
                        ).order("transacted_at ASC").last

        next_payment        = o.amortization_schedule_entries.unpaid.first
        next_payment_amount = ::Billings::NextLoanPaymentAmount.new(
                                config: { loan: o }
                              ).execute!

        last_payment_amount = last_payment.try(:amount) || 0.00
        past_due = ::Loans::PastDueAsOf.new(
                      config: { loan: o }
                    ).execute!

        @loans << {
          id: o.id,
          principal: number_to_currency(o.principal, unit: ""),
          interest: number_to_currency(o.interest, unit: ""),
          total_dues: number_to_currency(o.total_dues, unit: ""),
          total_balance: number_to_currency(o.total_balance, unit: ""),
          total_paid: number_to_currency(o.total_paid, unit: ""),
          loan_product: o.loan_product.to_s,
          pn_number: o.pn_number,
          next_payment_amount: number_to_currency(next_payment_amount, unit: ""),
          next_payment_date: next_payment.due_date.strftime("%D"),
          last_payment_amount: number_to_currency(last_payment_amount, unit: ""),
          last_payment_date: last_payment.present? ? last_payment.transacted_at.strftime("%D") : "N/A",
          past_due: past_due
        }

        @total_balance += o.total_balance
        @total_loan += o.principal
        @total_interest += o.interest 
        @total_amount = @total_loan + @total_interest
        @total_paid += o.total_paid
        @next_payment_total_amount += next_payment_amount
        @total_past_due += past_due
        @next_payment_date = next_payment.due_date.strftime("%D")
      end

      @data = {
        loans: @loans,
        total_balance: number_to_currency(@total_balance, unit: ""),
        total_loan: number_to_currency(@total_loan, unit: ""),
        total_interest: number_to_currency(@total_interest, unit: ""),
        total_balance: number_to_currency(@total_balance, unit: ""),
        total_amount: number_to_currency(@total_amount, unit: ""),
        total_paid: number_to_currency(@total_paid, unit: ""),
        next_payment_total_amount: number_to_currency(@next_payment_total_amount, unit: ""),
        beggining_balance: @total_amount,
        total_past_due: number_to_currency(@total_past_due,unit: ""),
        next_payment_date: @next_payment_date
      }

      @data
    end
  end
end
