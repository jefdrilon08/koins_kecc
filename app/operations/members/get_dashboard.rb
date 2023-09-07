module Members
  class GetDashboard
    attr_accessor :payload

    def initialize(member:)
      @member = member

      @payload = {
        available_balance: 0.00
      }
    end

    def execute!
      # Savings
      @payload[:available_balance] = @member.member_accounts.sum(:balance).to_f
    end
  end
end
