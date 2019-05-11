module Adjustments
  module SubsidiaryAdjustments
    class Create
      def initialize(config:)
        @config = config
        @branch = @config[:branch]
        @user   = @config[:user]
      end

      def execute!
        @meta = {
          date_generated: Date.today,
          branch: {
            id: @branch.id,
            name: @branch.name
          },
          generated_by: @user
        }

        @data = {
          records: [],
          accounting_entry: {
          }
        }

        @adjustment_record  = AdjustmentRecord.new(
                                adjustment_type: "subsidiary",
                                meta: @meta,
                                data: @data
                              )

        @adjustment_record.save!

        @adjustment_record
      end
    end
  end
end
