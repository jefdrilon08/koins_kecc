module MonthlyClosingCollections
  class Approve
    def initialize(config:)
      @config = config

      @monthly_closing_collection = @config[:monthly_closing_collection]
      @closing_date               = @monthly_closing_collection.closing_date
      @data                       = @monthly_closing_collection.data.with_indifferent_access
      @user                       = @config[:user]
      @current_date               = Date.today

      @data_accounting_entry  = @data[:accounting_entry]

      # Change this
      @particular = "Interest deposit"
    end

    def execute!
      post_accounting_entry!
      perform_deposits!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @monthly_closing_collection.update!(
        status: "approved",
        closed_at: @current_date,
        data: @data
      )

      @monthly_closing_collection
    end

    private

    def post_accounting_entry!
      # Create new accounting entry
      config  = {
        accounting_entry_data: @data_accounting_entry,
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

    def perform_deposits!
      @data[:records].each do |r|
        member_account  = MemberAccount.find(r[:member_account][:id])
        member          = member_account.member

        config  = {
          date_paid: @closing_date,
          deposit: r,
          member: member,
          user: @user,
          particular: @particular
        }

        ::MonthlyClosingCollections::ApproveDepositHash.new(
          config: config
        ).execute!
      end
    end
  end
end
