module CommissionCollections
  class Approve
    def initialize(config:)
      @config                    = config
      @commission_collection     = @config[:commission_collection]
      @user                      = @config[:user]
      @data                      = @commission_collection.try(:data).try(:with_indifferent_access)
      @data_accounting_entry     = @data[:accounting_entry]
      @branch                    = Branch.where(id: Settings.try(:defaults).try(:default_branch).try(:id)).first
      @c_working_date            = Date.today

      # @c_working_date            = ::Utils::GetCurrentDate.new(
      #                               config: {
      #                                 branch: @branch
      #                               }
      #                             ).execute!
    end

    def execute!
      post_accounting_entry!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by     
    
      @commission_collection.update!(
        status: "approved",
        updated_at: @c_working_date,
        date_approved: @c_working_date,
        data: @data
      )

      @claim
    end

    private

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
