module Members
  class GetDashboard
    attr_accessor :payload

    def initialize(member:)
      @member = member

      @payload = {
        total_funds: 0.00
      }
    end

    def execute!
      # Savings
      @payload[:total_funds] = @member.member_accounts.sum(:balance).to_f
    end
  end
end
