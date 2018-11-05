module Billings
  class NextLoanPaymentAmount
    def initialize(config:)
      @config       = config
      @loan         = @config[:loan]
      @current_date = @config[:current_date] || Date.today
    end

    def execute!
      amount  = @loan.amortization_schedule_entries.unpaid.where(
                  "due_date <= ?",
                  @current_date
                ).sum("principal_balance + interest_balance").round(2)

      amount
    end
  end
end
