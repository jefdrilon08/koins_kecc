module Adjustments
  module BatchMoratoriumAdjustments
    class ValidateApprove < AppValidator
      def initialize(config:)
        super()

        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]

        @data = @adjustment_record.data.with_indifferent_access
      end

      def execute!
        validate_general!

        not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end

      private

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
