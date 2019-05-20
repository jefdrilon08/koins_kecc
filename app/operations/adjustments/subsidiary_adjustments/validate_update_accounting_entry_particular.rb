module Adjustments
  module SubsidiaryAdjustments
    class ValidateUpdateAccountingEntryParticular < AppValidator
      def initialize(config:)
        super()

        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]
        @particular         = @config[:particular]
      end

      def execute!
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

        if @particular.blank?
          @errors[:messages] << {
            key: "particular",
            message: "Particular not found"
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
