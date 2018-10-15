module Accounting
  module AccountingEntries
    class Fetch
      def initialize(config:)
        @config = config

        @book             = @config[:book]
        @reference_number = @config[:reference_number]
        @branch           = @config[:branch]

        @accounting_entry = {
          book: @book,
          reference_number: @reference_number,
          branch_id: @branch.try(:id),
          branch_name: @branch.try(:name),
          particular: "",
          date_prepared: Date.today,
          data: {
            or_number: "",
            check_number: "",
            check_voucher_number: "",
            date_of_check: "",
            sub_reference_number: ""
          },
          journal_entries: []
        }

        @existing_accounting_entry  = AccountingEntry.where(
                                        book: @book,
                                        reference_number: @reference_number,
                                        branch_id: @branch.try(:id)
                                      ).first
      end

      def execute!
        if @existing_accounting_entry.present?
          journal_entries = @accounting_entry.journal_entries

          journal_entries.each do |o|
            @accounting_entry[:journal_entries] << {
              id: o.id,
              post_type: o.post_type,
              accounting_code_id: o.accounting_code_id,
              accounting_code_name: o.accounting_code.name,
              amount: o.amount
            }
          end
        end

        @accounting_entry
      end
    end
  end
end
