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

      # Set previously processing loans to active
      if @loan.restructured?
        @loan.data["restructured_loans"].each do |o|
          Loan.find(o["id"]).update!(status: "active")
        end
      end

      # Delete loan
      @loan.destroy!
    end
  end
end
