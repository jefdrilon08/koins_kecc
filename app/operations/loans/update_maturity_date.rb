module Loans
  class UpdateMaturityDate
    def initialize(loan:)
      @loan = loan
    end

    def execute!
      maturity_date = AmortizationScheduleEntry.where(loan_id: @loan.id).order(
                        "due_date ASC"
                      ).last.due_date

      @loan.update!(
        maturity_date: maturity_date
      )
    end
  end
end
