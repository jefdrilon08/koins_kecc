module Adjustments
  module BatchMoratoriumAdjustments
    class Approve
      def initialize(config:)
        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]

        @data = @adjustment_record.data.with_indifferent_access
      end

      def execute!
      end
    end
  end
end
