module Accounting
  module AccountingEntries
    class GenerateSubReferenceNumber
      def initialize(book:, branch:, accounting_fund:)
        @book   = book
        @branch = branch
        @accounting_fund = accounting_fund

        @sub_reference_number = ""

        @latest_entry = AccountingEntry.approved.where(
                          book: @book,
                          branch_id: @branch.id,
                          accounting_fund_id: @accounting_fund.id
                        ).last
      end

      def execute!
        next_number = 1

        if @latest_entry.present?
          next_number = next_number = @latest_entry.data.with_indifferent_access[:sub_reference_number].split('-').last.to_i + 1
        end

        @sub_reference_number = "#{@book}-#{@accounting_fund.prefix}-#{next_number.to_s.rjust(10, "0")}"
      end
    end
  end
end
