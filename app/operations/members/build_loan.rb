module Members
  class BuildLoan
    attr_accessor :loan,
                  :payload

    def initialize(loan:)
      @loan         = loan
      @current_date = Date.today

      @payload = {
      }
    end

    def execute!
      @payload[:id]                    = @loan.id
      @payload[:pn_number]             = @loan.pn_number
      @payload[:status]                = @loan.status
      @payload[:loan_product]          = @loan.loan_product.try(:name)
      @payload[:principal]             = @loan.principal.to_f
      @payload[:interest]              = @loan.interest.to_f
      @payload[:principal_paid]        = @loan.principal_paid.to_f
      @payload[:interest_paid]         = @loan.interest_paid.to_f
      @payload[:principal_balance]     = @loan.principal_balance.to_f
      @payload[:interest_balance]      = @loan.interest_balance.to_f
      @payload[:total_balance]         = @loan.total_balance.to_f
      @payload[:total_paid]            = @loan.total_paid.to_f
      @payload[:maturity_date]         = @loan.maturity_date.try(:to_date).strftime("%b %d, %Y")
      @payload[:first_date_of_payment] = @loan.first_date_of_payment.try(:to_date).strftime("%b %d, %Y")
      @payload[:max_active_date]       = @loan.max_active_date.try(:to_date).strftime("%b %d, %Y")
      @payload[:loan_product_type]     = @loan.loan_product_type.try(:name)

      # Next date of payment
      unpaid_records = @loan.amortization_schedule_entries.unpaid.order("due_date DESC")
      @payload[:next_payment_date] = unpaid_records.where(
        "due_date <= ?", 
        @current_date
      ).first.try(:due_date).try(:to_date).try(:strftime, "%b %d, %Y")

      if @payload[:next_payment_date].present? and @payload[:next_payment_date].to_date < @current_date
        @payload[:is_overdue] = "yes"
      else
        @payload[:is_overdue] = "no"
      end

      ###########################

      running_balance = @loan.total_dues

      @payload[:amortization_schedule] = @loan.amortization_schedule_entries.order(
        "due_date ASC"
      ).map{ |amort|
        running_balance = (running_balance - amort.total_paid)

        {
          id:               amort.id,
          due_date:         amort.due_date.strftime("%b %d, %Y"),
          amount_due:       amort.amount_due,
          total_paid:       amort.total_paid.to_f,
          running_balance:  running_balance.to_f,
          is_paid:          amort.is_paid ? "yes" : "no"
        }
      }

      @payload[:payments] = AccountTransaction.where(
        subsidiary_id: @loan.id
      ).approved_loan_payments.map{ |payment|
        {
          id:             payment.id,
          amount:         payment.amount.to_f,
          transacted_at:  payment.transacted_at.to_date.strftime("%b %d, %Y")
        }
      }

      @payload
    end
  end
end
