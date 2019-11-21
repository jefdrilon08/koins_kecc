module Adjustments
  module SubsidiaryAdjustments
    class ValidateApprove < AppValidator
      def initialize(config:)
        super()

        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]

        @data = @adjustment_record.data.with_indifferent_access

        @records          = @data[:records]
        @accounting_entry = @data[:accounting_entry]
      end

      def execute!
        validate_general!
        validate_adjustments!
        validate_accounting_entry!

        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end

      private

      def validate_adjustments!
        if @records.size == 0
          @errors[:messages] << {
            key: "adjustments",
            message: "No adjustments found."
          }
        end
      end

      def validate_accounting_entry!
        if @accounting_entry[:particular].blank?
          @errors[:messages] << {
            key: "accounting_entry",
            message: "No particular found"
          }
        end

        if @accounting_entry[:journal_entries].size == 0
          @errors[:messages] << {
            key: "accounting_entry",
            message: "No journal entries found"
          }
        else
          total_debit   = 0.00
          total_credit  = 0.00

          @accounting_entry[:debit_journal_entries].each do |o|
            total_debit += o[:amount].to_f.round(2)
          end

          @accounting_entry[:credit_journal_entries].each do |o|
            total_credit += o[:amount].to_f.round(2)
          end


          total_debit   = total_debit.round(2)
          total_credit  = total_credit.round(2)

          if total_debit != total_credit
            @errors[:messages] << {
              key: "accounting_entry",
              message: "Imbalanced entries. DEBIT: #{total_debit} CREDIT: #{total_credit}"
            }
          end

          if total_debit == 0.00
            @errors[:messages] << {
              key: "accounting_entry",
              message: "No debit amount"
            }
          end

          if total_credit == 00
            @errors[:messages] << {
              key: "accounting_entry",
              message: "No credit amount"
            }
          end
        end
      end

      def validate_general!
        if @adjustment_record.blank?
          @errors[:messages] << {
            key: "adjustment_record",
            message: "Adjustment record not found"
          }
        elsif !@adjustment_record.pending?
          @errors[:messages] << {
            key: "adjustment_record",
            message: "Adjustment record not pending"
          }
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "User not found"
          }
        end

      end
    end
  end
end
