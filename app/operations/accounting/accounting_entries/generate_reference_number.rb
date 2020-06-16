module Accounting
  module AccountingEntries
    class GenerateReferenceNumber
      def initialize(book:, branch:)
        @book   = book.try(:upcase)
        @branch = branch

        @reference_number = ""

        @latest_entry = AccountingEntry.approved.where(
                          book: @book,
                          branch_id: @branch.id
                        ).last
      end

      def execute!
        next_number = 1

        if @latest_entry.present?
          next_number = @latest_entry.reference_number.to_i + 1
        end

        @reference_number = next_number.to_s.rjust(10, "0")
      end
    end
  end
end
