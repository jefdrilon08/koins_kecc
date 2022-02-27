module Members
  class BuildLoan
    attr_accessor :loan,
                  :data

    def initialize(loan:)
      @loan = loan

      @data = {
      }
    end

    def execute!
      @data[:id]                    = @loan.id
      @data[:pn_number]             = @loan.pn_number
      @data[:status]                = @loan.status
      @data[:loan_product]          = @loan.loan_product.try(:name)
      @data[:principal]             = @loan.principal.to_f
      @data[:interest]              = @loan.interest.to_f
      @data[:principal_paid]        = @loan.principal_paid.to_f
      @data[:interest_paid]         = @loan.interest_paid.to_f
      @data[:principal_balance]     = @loan.principal_balance.to_f
      @data[:interest_balance]      = @loan.interest_balance.to_f
      @data[:total_balance]         = @loan.total_balance.to_f
      @data[:total_paid]            = @loan.total_paid.to_f
      @data[:maturity_date]         = @loan.maturity_date.try(:to_date).strftime("%b %d, %Y")
      @data[:first_date_of_payment] = @loan.first_date_of_payment.try(:to_date).strftime("%b %d, %Y")
      @data[:max_active_date]       = @loan.max_active_date.try(:to_date).strftime("%b %d, %Y")
      @data[:loan_product_type]     = @loan.loan_product_type.try(:name)

      running_balance = @loan.total_dues

      @data[:amortization_schedule] = @loan.amortization_schedule_entries.order("due_date ASC").map{ |amort|
        running_balance = (running_balance - amort.total_paid)

        {
          id:               amort.id,          
          amount_due:       amort.amount_due,
          total_paid:       amort.total_paid,
          running_balance:  running_balance,
        }
      }

      @data[:payments] = AccountTransaction.where(subsidiary_id: @loan.id).approved_loan_payments.map{ |payment|
        {
          id:             payment.id,
          amount:         payment.amount.to_f,
          transacted_at:  payment.transacted_at.to_date.strftime("%b %d, %Y")
        }
      }

      @data
    end
  end
end
