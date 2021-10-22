module Loans
  class AddReverseReason
    def initialize(config:)
      @config = config
      @loan = Loan.find(@config[:loan].id)
      @loan_data = @loan.data.with_indifferent_access
      @reason_details = @config[:reason_details]

    end
    def execute!
      loan_data_reverse = @loan_data[:reverse_loan_details].select{ |o|  o[:status] == "pending" }.last
      loan_data_reverse[:reason] = @reason_details 

      @loan.update!(data: @loan_data)
      @loan
    end

  end
end
