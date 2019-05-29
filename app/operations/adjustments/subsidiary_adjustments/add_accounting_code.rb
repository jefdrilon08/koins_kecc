module Adjustments
  module SubsidiaryAdjustments
    class AddAccountingCode
      def initialize(config:)
        @config = config

        @adjustment_record  = @config[:adjustment_record]
        @accounting_code    = @config[:accounting_code]
        @amount             = @config[:amount].to_f.round(2)
        @post_type          = @config[:post_type]

        @data             = @adjustment_record.data.with_indifferent_access
        @accounting_entry = @data[:accounting_entry]
      end

      def execute!
        if @post_type == "DR"
          @accounting_entry[:debit_journal_entries] << {
            accounting_code_id: @accounting_code.id,
            code: @accounting_code.code,
            name: @accounting_code.name,
            amount: @amount
          }
        elsif @post_type == "CR"
          @accounting_entry[:credit_journal_entries] << {
            accounting_code_id: @accounting_code.id,
            code: @accounting_code.code,
            name: @accounting_code.name,
            amount: @amount
          }
        end

        # Build journal entries
        @accounting_entry[:journal_entries] = []  # reset first

        @accounting_entry[:debit_journal_entries].each do |j|
          @accounting_entry[:journal_entries] << {
            id: "",
            post_type: "DR",
            accounting_code_id: j[:accounting_code_id],
            accounting_code_name: "#{j[:code]} - #{j[:name]}",
            amount: j[:amount]
          }
        end

        @accounting_entry[:credit_journal_entries].each do |j|
          @accounting_entry[:journal_entries] << {
            id: "",
            post_type: "CR",
            accounting_code_id: j[:accounting_code_id],
            accounting_code_name: "#{j[:code]} - #{j[:name]}",
            amount: j[:amount]
          }
        end

        @data[:accounting_entry]  = @accounting_entry

        @adjustment_record.data = @data

        @adjustment_record.save!
      end
    end
  end
end
