module Accounting
  module AccountingEntries
    class ValidateModifyDatePosted < AppValidator
      def initialize(config:)
        super()
        @config           = config
        @accounting_entry = AccountingEntry.where(id: @config[:id]).first
        @orig_date_posted = @accounting_entry.try(:date_posted)
        @date_posted      = @config[:date_posted].try(:to_date)
      end

      def execute!
        # Validate same date posted
        if @date_posted.blank?
          @errors[:messages] << {
            key: "date_posted",
            message: "Date posted required"
          }
        end

        if @date_posted.present?
          if @orig_date_posted == @date_posted
            @errors[:messages] << {
              key: "date_posted",
              message: "Same date posted value"
            }
          end
        end

        # TODO: Validate user

        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
    end
  end
end
