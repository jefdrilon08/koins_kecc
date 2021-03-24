module EquityWithdrawalCollections
  class Approve
    def initialize(config:)
      @config                           = config
      @equity_withdrawal_collection     = @config[:equity_withdrawal_collection]
      @user                             = @config[:user]


      @data                             = @equity_withdrawal_collection.try(:data).try(:with_indifferent_access)
      @data_withdrawals                 = @equity_withdrawal_collection.withdrawals
      

      @branch                           = @equity_withdrawal_collection.branch
      @date_approved                    = ::Utils::GetCurrentDate.new(
                                                      config: {
                                                        branch: @branch
                                                      }
                                                    ).execute!
    end

    def execute!
      process_withdrawals!

      @data[:approved_by] = @user.full_name

      @equity_withdrawal_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @equity_withdrawal_collection
    end

    private

    def process_withdrawals!
      @data_withdrawals.each do |o|
        config  = {
          date_paid: @date_approved,
          equity_withdrawal: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data[:particular]
        }

        ::EquityWithdrawalCollections::ApproveEquityWithdrawalHash.new(
          config: config
        ).execute!
      end
    end
  end
end
