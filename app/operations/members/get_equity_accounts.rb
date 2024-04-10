module Members
  class GetEquityAccounts
    attr_accessor  :payload

    def initialize(member:)
      @member   = member
      @accounts = @member.member_accounts.equities

      @payload = {
        balance: 0.0,
        accounts: []
      }
    end

    def execute!
      # Balance
      @payload[:balance] = @accounts.sum(:balance)

      # Accounts
      @payload[:accounts] = @accounts.map{ |o|
        o.to_v2_hash
      }
    end
  end
end
