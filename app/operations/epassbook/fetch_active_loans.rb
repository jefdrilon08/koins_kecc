module Epassbook
  class FetchActiveLoans
    include ActionView::Helpers::NumberHelper

    def initialize(member:)
      @member                 = member
      @active_loans           = @member.loans.active
      @pending_loans          = @member.loans.pending
      @for_verification_loans = @member.loans.for_verification
      @verified_loans         = @member.loans.verified
      @in_process_loans       = @member.loans.in_process

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

      last_payment  = AccountTransaction.approved_loan_payments.where(
                        subsidiary_id: @active_loans.pluck(:id),
                        subsidiary_type: "Loan"
                      ).order("transacted_at ASC").last

      last_payment_amount = last_payment.try(:amount) || 0.00
      last_payment_date   = last_payment.try(:transacted_at).try(:strftime, "%D") || ""

      pending_loans = @pending_loans.map{ |o|
        {
          id: o.id,
          principal: number_to_currency(o.principal, unit: ""),
          interest: number_to_currency(o.interest, unit: ""),
          total_dues: number_to_currency(o.total_dues, unit: ""),
          total_balance: number_to_currency(o.total_balance, unit: ""),
          total_paid: number_to_currency(o.total_paid, unit: ""),
          loan_product: o.loan_product.to_s
        }
      }

      for_verification_loans  = @for_verification_loans.map{ |o|
        {
          id: o.id,
          principal: number_to_currency(o.principal, unit: ""),
          interest: number_to_currency(o.interest, unit: ""),
          total_dues: number_to_currency(o.total_dues, unit: ""),
          total_balance: number_to_currency(o.total_balance, unit: ""),
          total_paid: number_to_currency(o.total_paid, unit: ""),
          loan_product: o.loan_product.to_s
        }
      }

      in_process_loans  = @in_process_loans.map{ |o|
        {
          id: o.id,
          principal: number_to_currency(o.principal, unit: ""),
          interest: number_to_currency(o.interest, unit: ""),
          total_dues: number_to_currency(o.total_dues, unit: ""),
          total_balance: number_to_currency(o.total_balance, unit: ""),
          total_paid: number_to_currency(o.total_paid, unit: ""),
          loan_product: o.loan_product.to_s
        }
      }
      
      verified_loans  = @verified_loans.map{ |o|
        {
          id: o.id,
          principal: number_to_currency(o.principal, unit: ""),
          interest: number_to_currency(o.interest, unit: ""),
          total_dues: number_to_currency(o.total_dues, unit: ""),
          total_balance: number_to_currency(o.total_balance, unit: ""),
          total_paid: number_to_currency(o.total_paid, unit: ""),
          loan_product: o.loan_product.to_s
        }
      }

      @data = {
        loans: @loans,
        pending_loans: pending_loans,
        for_verification_loans: for_verification_loans,
        in_process_loans: in_process_loans,
        verified_loans: verified_loans,
        total_balance: number_to_currency(@total_balance, unit: ""),
        total_loan: number_to_currency(@total_loan, unit: ""),
        total_interest: number_to_currency(@total_interest, unit: ""),
        total_balance: number_to_currency(@total_balance, unit: ""),
        total_amount: number_to_currency(@total_amount, unit: ""),
        total_paid: number_to_currency(@total_paid, unit: ""),
        next_payment_total_amount: number_to_currency(@next_payment_total_amount, unit: ""),
        beggining_balance: @total_amount,
        total_past_due: number_to_currency(@total_past_due,unit: ""),
        next_payment_date: @next_payment_date,
        last_payment_amount: last_payment_amount,
        last_payment_date: last_payment_date,
        count_pending_loans: @pending_loans.count
      }

      @data
    end
  end
end
