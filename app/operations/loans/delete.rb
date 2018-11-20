module Loans
  class Delete
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]
    end

    def execute!
      # Delete amort
      amorts  = AmortizationScheduleEntry.where(
                  loan_id: @loan.id
                )

      amorts.delete_all

      # Delete loan
      @loan.destroy!
    end
  end
end
