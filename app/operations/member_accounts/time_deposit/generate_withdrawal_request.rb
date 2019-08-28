module MemberAccounts
  module TimeDeposit
    class GenerateWithdrawalRequest
      def initialize(config:)
        @config         = config
        @member_account = @config[:member_account]
        @branch         = @config[:branch]

        @current_date = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!

        @balance  = @member_account.balance.to_f.round(2)
        @interest = 0.00

        @data = {
          branch: {
            id: @branch.id,
            name: @branch.name
          }
        }
      end

      def execute!
      end
    end
  end
end
