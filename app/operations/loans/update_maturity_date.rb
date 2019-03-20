module Loans
  class UpdateMaturityDate
    def initialize(loan:)
      @loan = loan
    end

    def execute!
      maturity_date = @loan.amortization_schedule_entries.order(
                        "due_date ASC"
                      ).last.due_date

      @loan.update!(
        maturity_date: maturity_date
      )
    end
  end
end
