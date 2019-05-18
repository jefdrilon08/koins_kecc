module Adjustments
  module SubsidiaryAdjustments
    class ValidateAddAccountingCode < AppValidator
      def initialize(config:)
        super()

        @config = config

        @adjustment_record  = @config[:adjustment_record]
        @accounting_code    = @config[:accounting_code]
        @amount             = @config[:amount].to_f.round(2)
        @post_type          = @config[:post_type]
      end

      def execute!
        if @accounting_code.blank?
          @errors[:messages] << {
            key: "accounting_code",
            message: "Accounting code not found"
          }
        end

        if @post_type.blank?
          @errors[:messages] << {
            key: "post_type",
            message: "Post type not found"
          }
        elsif !["DR", "CR"].include?(@post_type)
          @errors[:messages] << {
            key: "post_type",
            message: "Invalid post type #{@post_type}"
          }
        end

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

        if @amount.blank?
          @errors[:messages] << {
            key: "amount",
            message: "Amount not found"
          }
        elsif @amount <= 0.00
          @errors[:messages] << {
            key: "amount",
            message: "Invalid amount #{@amount}"
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
