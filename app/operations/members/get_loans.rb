module Members
  class GetLoans
    attr_accessor :member,
                  :loans,
                  :payload

    def initialize(member:, status: "active")
      @member = member
      @status = status
      @loans  = []

      @current_date = Date.today

      @payload = {}
    end

    def execute!
      current_loans = ReadOnlyLoan.where(
        status: @status,
        member_id: @member.id
      ).order("date_approved DESC")

      total_principal         = current_loans.sum(:principal).to_f
      total_interest          = current_loans.sum(:interest).to_f
      total_principal_paid    = current_loans.sum(:principal_paid).to_f
      total_interest_paid     = current_loans.sum(:interest_paid).to_f
      total_principal_balance = current_loans.sum(:principal_balance).to_f
      total_interest_balance  = current_loans.sum(:interest_balance).to_f
      total_amount            = (total_principal + total_interest).to_f
      total_balance           = (total_principal_balance + total_interest_balance).to_f

      current_loans.each do |o|
        @loans << build_loan(o)
      end

      # Build values
      @payload[:total_principal]         = total_principal.to_f
      @payload[:total_interest]          = total_interest.to_f
      @payload[:total_principal_balance] = total_principal_balance.to_f
      @payload[:total_interest_balance]  = total_interest_balance.to_f
      @payload[:total_principal_paid]    = total_principal_paid.to_f
      @payload[:total_interest_paid]     = total_interest_paid.to_f
      @payload[:total_amount]            = total_amount.to_f
      @payload[:total_balance]           = total_balance.to_f

      @payload[:loans] = @loans

      @payload
    end

    private

    def build_loan(loan)
      obj = {
        id:                     loan.id,
        pn_number:              loan.pn_number,
        principal:              loan.principal,
        interest:               loan.interest.to_f,
        principal_paid:         loan.principal_paid.to_f,
        interest_paid:          loan.interest_paid.to_f,
        principal_balance:      loan.principal_balance.to_f,
        interest_balance:       loan.interest_balance.to_f,
        loan_product:           loan.loan_product.name,
        total_balance:          loan.total_balance,
        date_approved:          loan.date_approved.try(:to_date).try(:strftime, "%b %d, %Y"),
        maturity_date:          loan.maturity_date.try(:to_date).try(:strftime, "%b %d, %Y"),
        first_date_of_payment:  loan.first_date_of_payment.try(:to_date).try(:strftime, "%b %d, %Y"),
        max_active_date:        loan.max_active_date.try(:to_date).try(:strftime, "%b %d, %Y"),
        loan_product_type:      loan.loan_product_type.try(:name)
      }

      unpaid_records = loan.amortization_schedule_entries.unpaid.order("due_date DESC")
      
      obj[:current_principal_balance] = unpaid_records.where(
                                          "due_date <= ?",
                                          @current_date
                                        ).sum(:principal_balance).to_f

      obj[:current_interest_balance]  = unpaid_records.where(
                                          "due_date <= ?",
                                          @current_date
                                        ).sum(:interest_balance).to_f

      obj[:current_balance] = (obj[:current_principal_balance] + obj[:current_interest_balance]).to_f

      obj[:next_payment_date] = unpaid_records.where("due_date <= ?", @current_date).first.try(:due_date).try(:to_date)

      if obj[:next_payment_date].present? and obj[:next_payment_date] < @current_date
        obj[:next_payment_date] = @current_date
        obj[:is_overdue] = "yes"
      else
        obj[:is_overdue] = "no"
      end

      # Format dates
      obj[:next_payment_date] = obj[:next_payment_date].try(:to_date).try(:strftime, "%b %d, %Y")

      obj
    end
  end
end
