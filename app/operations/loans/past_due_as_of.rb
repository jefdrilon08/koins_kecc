module Loans
  class PastDueAsOf
    def initialize(config:)
      @as_of  = config[:as_of].try(:to_date) || Date.today
      @loan   = config[:loan]

      @approved_loan_payments = AccountTransaction.approved_loan_payments.where(
                                  "subsidiary_id = ? AND transacted_at  <= ?",
                                  @loan.id,
                                  @as_of
                                )

      @amortization_schedule_entries  = @loan.amortization_schedule_entries.where(
                                          "due_date < ?",
                                          @as_of
                                        ).order("due_date ASC")
    end

    def execute!
      @past_due = @amortization_schedule_entries.sum("principal + interest") - @approved_loan_payments.sum(:amount)

      if @past_due < 0
        @past_due = 0.00
      end

      @past_due
    end
  end
end
