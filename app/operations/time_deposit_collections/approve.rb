module TimeDepositCollections
  class Approve
    def initialize(config:)
      @config             = config
      @time_deposit_collection = @config[:time_deposit_collection]
      @user               = @config[:user]

      @data = @time_deposit_collection.try(:data).try(:with_indifferent_access)
      @data_deposits          = @time_deposit_collection.deposits
      @data_accounting_entry  = @time_deposit_collection.accounting_entry

      @branch = @time_deposit_collection.branch

      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
    end

    def execute!
      post_accounting_entry!
      process_deposits!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @time_deposit_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @time_deposit_collection
    end

    private

    def process_deposits!
      @data_deposits.each do |o|
        config  = {
          date_paid: @date_approved,
          deposit: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::TimeDepositCollections::ApproveDepositHash.new(
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
