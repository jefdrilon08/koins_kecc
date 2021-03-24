module InsuranceWithdrawalCollections
  class Approve
    def initialize(config:)
      @config                           = config
      @insurance_withdrawal_collection  = @config[:insurance_withdrawal_collection]
      @user                             = @config[:user]

      @data                             = @insurance_withdrawal_collection.try(:data).try(:with_indifferent_access)
      @data_withdrawals                 = @insurance_withdrawal_collection.withdrawals
      @branch                           = @insurance_withdrawal_collection.branch
      @date_approved                    = ::Utils::GetCurrentDate.new(
                                            config: {
                                              branch: @branch
                                            }
                                          ).execute!
    end

    def execute!
      process_withdrawals!

      @data[:approved_by] = @user.full_name

      @insurance_withdrawal_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @insurance_withdrawal_collection
    end

    private

    def process_withdrawals!
      @data_withdrawals.each do |o|
        config  = {
          date_paid: @date_approved,
          insurance_withdrawal: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data[:particular]
        }

        ::InsuranceWithdrawalCollections::ApproveInsuranceWithdrawalHash.new(
          config: config
        ).execute!
      end
    end
  end
end
