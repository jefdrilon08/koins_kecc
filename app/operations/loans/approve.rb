module Loans
  class Approve
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]
      
      @current_date = Date.today
    end

    def execute!
      post_accounting_entry!
      @loan.update!(
        status: "active",
        date_approved: @current_date
      )

      @loan
    end

    private

    def post_accounting_entry!
      accounting_entry_data = @loan.data.with_indifferent_access[:accounting_entry]

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: {
                              id: nil,
                              accounting_entry_data: accounting_entry_data,
                              user: @user
                            }
                          ).execute!

      accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                            config: {
                              accounting_entry: accounting_entry,
                              user: @user
                            }
                          ).execute!

      # Update reference number
      data  = @loan.data.with_indifferent_access
      data[:accounting_entry][:reference_number] = accounting_entry.reference_number

      @loan.update!(
        data: data
      )
    end
  end
end
