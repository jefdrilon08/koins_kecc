module Closing
  class ApproveYearEndClosing
    def initialize(config:)
      @config = config

      @data_store = @config[:data_store]
      @user       = @config[:user]
      @meta       = @data_store.meta.with_indifferent_access
      @data       = @data_store.data.with_indifferent_access
      @branch     = Branch.find(@meta[:branch_id])

      @current_date = Date.today
    end

    def execute!
      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: {
                              accounting_entry_data: @data[:accounting_entry],
                              user: @user
                            }
                          ).execute!

      accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                            config: {
                              accounting_entry: accounting_entry,
                              user: @user
                            }
                          ).execute!

      @meta[:closed_by] = {
        id: @user.id,
        first_name: @user.first_name,
        last_name: @user.last_name
      }

      @meta[:date_closed] = @current_date
      
      @data[:accounting_entry][:reference_number] = accounting_entry.reference_number

      @data_store.update!(
        meta: @meta,
        data: @data,
        status: "closed"
      )

      @data_store
    end
  end
end
