module WithdrawalCollections
  class Approve
    def initialize(config:)
      @config   = config
      @withdrawal_collection  = @config[:withdrawal_collection]
      @user     = @config[:user]

      @data = @withdrawal_collection.try(:data).try(:with_indifferent_access)
      @data_withdrawals          = @withdrawal_collection.withdrawals
      @data_accounting_entry  = @withdrawal_collection.accounting_entry
    end

    def execute!
      post_accounting_entry!
      process_withdrawals!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @withdrawal_collection.update!(
        status: "approved",
        data: @data
      )

      @withdrawal_collection
    end

    private

    def process_withdrawals!
      @data_withdrawals.each do |o|
        config  = {
          date_paid: @withdrawal_collection.collection_date,
          withdrawal: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::WithdrawalCollections::ApproveWithdrawalHash.new(
          config: config
        ).execute!
      end
    end

    def post_accounting_entry!
      # Create new accounting entry
      config  = {
        accounting_entry_data: @data_accounting_entry.with_indifferent_access,
        user: @user
      }

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: config
                          ).execute!

      # Post to books
      config  = {
        accounting_entry: accounting_entry,
        user: @user
      }

      @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                            config: config
                          ).execute!

      @accounting_entry
    end
  end
end
