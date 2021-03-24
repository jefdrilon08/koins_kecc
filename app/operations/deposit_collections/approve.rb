module DepositCollections
  class Approve
    def initialize(config:)
      @config                 = config
      @deposit_collection     = @config[:deposit_collection]
      @user                   = @config[:user]

      @data                   = @deposit_collection.try(:data).try(:with_indifferent_access)
      @data_deposits          = @deposit_collection.deposits
      @data_accounting_entry  = @deposit_collection.accounting_entry

      @branch                 = @deposit_collection.branch

      @date_approved          = ::Utils::GetCurrentDate.new(
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
      @data[:accounting_entry][:id]                         = @accounting_entry.id
      @data[:accounting_entry][:reference_number]           = @accounting_entry.reference_number
      @data[:accounting_entry][:status]                     = @accounting_entry.status
      @data[:accounting_entry][:approved_by]                = @accounting_entry.approved_by
      @data[:accounting_entry][:sub_reference_number]       = @accounting_entry.sub_reference_number

      @deposit_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @deposit_collection
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

        ::DepositCollections::ApproveDepositHash.new(
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
