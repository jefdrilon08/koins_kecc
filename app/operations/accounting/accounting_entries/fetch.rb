module Accounting
  module AccountingEntries
    class Fetch
      def initialize(config:)
        @config = config

        @id               = @config[:id]
        @book             = @config[:book]
        @reference_number = @config[:reference_number]
        @branch           = @config[:branch]

        if @branch.blank?
          @branch = Branch.first
        end

        @accounting_entry = {
          book: @book,
          reference_number: @reference_number,
          branch_id: @branch.try(:id),
          branch_name: @branch.try(:name),
          particular: "",
          date_prepared: Date.today,
          status: "pending",
          data: {
            or_number: "",
            check_number: "",
            check_voucher_number: "",
            date_of_check: "",
            sub_reference_number: "",
            payee: ""
          },
          journal_entries: []
        }

        if @id.present?
          @existing_accounting_entry = AccountingEntry.find(@id)
        end
      end

      def execute!
        if @existing_accounting_entry.present?
          @accounting_entry[:status]            = @existing_accounting_entry.status
          @accounting_entry[:date_prepared]     = @existing_accounting_entry.date_prepared
          @accounting_entry[:book]              = @existing_accounting_entry.book
          @accounting_entry[:reference_number]  = @existing_accounting_entry.reference_number
          @accounting_entry[:branch_id]         = @existing_accounting_entry.branch.try(:id)
          @accounting_entry[:branch_name]       = @existing_accounting_entry.branch.try(:name)
          @accounting_entry[:particular]        = @existing_accounting_entry.particular
          @accounting_entry[:data]              = @existing_accounting_entry.data

          journal_entries = @existing_accounting_entry.journal_entries

          journal_entries.each do |o|
            @accounting_entry[:journal_entries] << {
              id: o.id,
              post_type: o.post_type,
              accounting_code_id: o.accounting_code_id,
              accounting_code_name: "#{o.accounting_code.code} - #{o.accounting_code.name}",
              amount: o.amount
            }
          end
        end

        @accounting_entry
      end
    end
  end
end
