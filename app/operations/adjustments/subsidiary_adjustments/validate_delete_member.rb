module Adjustments
  module SubsidiaryAdjustments
    class ValidateDeleteMember < AppValidator
      def initialize(config:)
        super()

        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @member_account     = @config[:member_account]
        @user               = @config[:user]
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

        if @member_account.blank?
          @errors[:messages] << {
            key: "member_account",
            message: "Member account not found"
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
