module Adjustments
  module BatchMoratoriumAdjustments
    class ValidateCreate < AppValidator
      def initialize(config:)
        super()

        @config           = config
        @branch           = @config[:branch]
        @center           = @config[:center]
        @number_of_days   = @config[:number_of_days].try(:to_i)
        @reason           = @config[:reason]
        @date_initialized = @config[:date_initialized]
        @user             = @config[:user]
      end

      def execute!
        if @branch.blank?
          @errors[:messages] << {
            key: "branch",
            message: "Branch not found"
          }
        end

        if @number_of_days.blank?
          @errors[:messages] << {
            key: "number_of_days",
            message: "Number of days not found"
          }
        elsif @number_of_days == 0
          @errors[:messages] << {
            key: "number_of_days",
            message: "Number of days cannot be 0"
          }
        end

        if @date_initialized.blank?
          @errors[:messages] << {
            key: "date_initialized",
            message: "Date initialized required"
          }
        end

        if @reason.blank?
          @errors[:messages] << {
            key: "reason",
            message: "Reason required"
          }
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "User not found"
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
