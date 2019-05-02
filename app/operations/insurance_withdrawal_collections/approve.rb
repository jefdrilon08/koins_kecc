module InsuranceWithdrawalCollections
  class Approve
    def initialize(config:)
      @config                           = config
      @insurance_withdrawal_collection  = @config[:insurance_withdrawal_collection]
      @user                             = @config[:user]

      @data = @insurance_withdrawal_collection.try(:data).try(:with_indifferent_access)
      @data_withdrawals       = @insurance_withdrawal_collection.withdrawals
      @data_accounting_entry  = @withdrawal_collection.accounting_entry

      @date_approved  = Date.today

      if Settings.current_date.present?
        @date_approved  = Settings.current_date.to_date
      end
    end

    def execute!
      process_withdrawals!

      @data[:approved_by] = @user.full_name

      @withdrawal_collection.update!(
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
          withdrawal: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::InsuranceWithdrawalCollections::ApproveInsuranceWithdrawalHash.new(
          config: config
        ).execute!
      end
    end
  end
end
