module Accounting
  module AccountingEntries
    class Approve
      def initialize(config:)
        @config = config.with_indifferent_access

        @accounting_entry = @config[:accounting_entry]
        @book             = @accounting_entry.book
        @branch           = @accounting_entry.branch
        @user             = @config[:user]

        @current_date = Date.today
      end

      def execute!
        new_reference_number  = ::Accounting::AccountingEntries::GenerateReferenceNumber.new(
                                  book: @book,
                                  branch: @branch
                                ).execute!

        #raise new_reference_number.inspect

        @accounting_entry.update!(
          status: "approved",
          date_posted: @current_date,
          approved_by: @user.full_name,
          reference_number: new_reference_number
        )

        ActivityLog.create!(
          content: "#{@user.full_name} approved accounting entry #{@accounting_entry.id}",
          activity_type: "approval",
          data: {
            user_id: @user.id,
            accounting_entry_id: @accounting_entry.id
          }
        )

        @accounting_entry
      end
    end
  end
end
