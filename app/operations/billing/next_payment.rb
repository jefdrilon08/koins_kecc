module Billing
  class NextPayment
    def initialize(config:)
      @config = config
      @member = @member

      @active_loans = Loan.active.where(member_id: @member.id)
    end

    def execute!
    end
  end
end
