module Loans
  class Approve
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]
    end

    def execute!
      @loan.update!(status: "active")
    end
  end
end
