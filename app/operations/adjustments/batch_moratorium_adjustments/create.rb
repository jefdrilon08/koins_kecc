module Adjustments
  module BatchMoratoriumAdjustments
    class Create
      def initialize(config:)
        @config           = config
        @branch           = @config[:branch]
        @center           = @config[:center]
        @number_of_days   = @config[:number_of_days].try(:to_i)
        @reason           = @config[:reason]
        @date_initialized = @config[:date_initialized]
        @user             = @config[:user]
      end

      def execute!
        @meta = {
          date_generated: Date.today,
          branch: {
            id: @branch.id,
            name: @branch.name
          },
          center: {
            id: @center.try(:id),
            name: @center.try(:name)
          },
          generated_by: @user
        }

        @data = {
          date_initialized: @date_initialized,
          number_of_days: @number_of_days,
          reason: @reason
        }

        @adjustment_record  = AdjustmentRecord.new(
                                adjustment_type: "batch_moratorium",
                                meta: @meta,
                                data: @data
                              )

        @adjustment_record.save!

        @adjustment_record
      end
    end
  end
end
