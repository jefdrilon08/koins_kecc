module Accounting
  module AccountingEntries
    class ValidateApprove < AppValidator
      def initialize(config:)
        super()
        @config = config.with_indifferent_access

        @accounting_entry = @config[:accounting_entry]
        @user             = @config[:user]

        @journal_entries  = @accounting_entry.journal_entries
      end

      def execute!
        validate_balanced!

        # For microinsurance
        if Settings.activate_microinsurance
          if @accounting_entry.accounting_fund_id.nil?
            @errors[:messages] << {
              key: "accounting_fund",
              message: "Accounting Fund is required"
            }  
          end

          if @accounting_entry.branch_id != Settings.defaults[:default_branch][:id]
            @errors[:messages] << {
              key: "branch",
              message: "Wrong selected branch!"
            }
          end
        end

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end

      private

      def validate_balanced!
        debit_amount  = 0.00
        @journal_entries.debit.each do |o|
          debit_amount += o.amount.round(2)
        end

        credit_amount = 0.00
        @journal_entries.credit.each do |o|
          credit_amount += o.amount.round(2)
        end

        if debit_amount != credit_amount
          @errors[:messages] << {
            key: "journal_entries",
            message: "unbalanced entries. debit: #{debit_amount} credit: #{credit_amount}"
          }
        end
      end
    end
  end
end
