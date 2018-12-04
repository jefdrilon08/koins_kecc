module Accounting
  module AccountingEntries
    class ValidateSave < AppValidator
      def initialize(config:)
        super()
        @config = config.with_indifferent_access

        @accounting_entry_data  = @config[:accounting_entry_data]
        @user                   = @config[:user]
      end

      def execute!
        if @accounting_entry_data[:journal_entries].size <= 1
          @errors[:messages] << {
            key: "journal_entries",
            message: "no journal entries found"
          }
        else
          # TODO: Check balancing of journal entries
          dr_amount = 0.00
          cr_amount = 0.00
          
          @accounting_entry_data[:journal_entries].each do |o|
            if o[:post_type] == "DR"
              dr_amount += o[:amount].to_f
            elsif o[:post_type] == "CR"
              cr_amount += o[:amount].to_f
            end
          end

          dr_amount = dr_amount.round(2)
          cr_amount = cr_amount.round(2)

          if dr_amount != cr_amount
            @errors[:messages] << {
              key: "journal_entries",
              message: "unbalanced entries. dr: #{dr_amount} cr: #{cr_amount}"
            }
          end
        end

        # Check for book
        if @accounting_entry_data[:book].blank?
          @errors[:messages] << {
            key: "book",
            message: "Book required"
          }
        end

        # Check for particular
        if @accounting_entry_data[:particular].blank?
          @errors[:messages] << {
            key: "particular",
            message: "Particular required"
          }
        end

        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
    end
  end
end
