module MemberAccounts
  module TimeDeposit
    class FetchWithdrawalRequests
      def initialize(config:)
        @config         = config
        @member_account = @config[:member_account]

        if @member_account.blank?
          raise "Member account not found"
        end

        @data = {
          records: []
        }
      end

      def execute!
        @data[:records] = DataStore.time_deposit_withdrawal.where(
                            "meta->'member_account'->>'id' = ?",
                            @member_account.id
                          ).order("created_at ASC").map{ |o|
                            {
                              id: o.id,
                              status: o.status,
                              meta: o.meta,
                              data: o.data
                            }
                          }
        @data
      end
    end
  end
end
