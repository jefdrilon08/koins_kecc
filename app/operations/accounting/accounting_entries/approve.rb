module Accounting
  module AccountingEntries
    class Approve
      def initialize(config:)
        @config = config.with_indifferent_access

        @accounting_entry = @config[:accounting_entry]
        @book             = @accounting_entry.book
        @branch           = @accounting_entry.branch
        @user             = @config[:user]
        @data             = @accounting_entry.data.try(:with_indifferent_access)

        if @data.blank?
          @data = {}
        end

        @current_date = Date.today

        if Settings.current_date.present?
          @current_date = Settings.current_date.to_date
        end
      end

      def execute!
        new_reference_number  = ::Accounting::AccountingEntries::GenerateReferenceNumber.new(
                                  book: @book,
                                  branch: @branch
                                ).execute!

        @data[:sub_reference_number]  = ""

        if @accounting_entry.accounting_fund.present?
          @data[:sub_reference_number]  = ::Accounting::AccountingEntries::GenerateSubReferenceNumber.new(
                                            book: @book,
                                            branch: @branch,
                                            accounting_fund: @accounting_entry.accounting_fund
                                          ).execute!
        end

        #raise new_reference_number.inspect

        @accounting_entry.update!(
          status: "approved",
          date_posted: @current_date,
          approved_by: @user.full_name,
          reference_number: new_reference_number,
          data: @data
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
