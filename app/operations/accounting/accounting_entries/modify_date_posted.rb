module Accounting
  module AccountingEntries
    class ModifyDatePosted < AppValidator
      def initialize(config:)
        @config           = config
        @accounting_entry = AccountingEntry.where(id: @config[:id]).first
        @orig_date_posted = @accounting_entry.date_posted
        @date_posted      = @config[:date_posted].try(:to_date)
        @user             = @config[:user]
      end

      def execute!
        @accounting_entry.update!(
          date_posted: @date_posted
        )

        ActivityLog.create!(
          content: "#{@user.full_name} modified date posted of accounting entry #{@accounting_entry.id} from #{@orig_date_posted} to #{@date_posted}",
          activity_type: "correction",
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
