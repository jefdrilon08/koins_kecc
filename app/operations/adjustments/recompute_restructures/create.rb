module Adjustments
  module RecomputeRestructures
    class Create

      def initialize(config:)
        @config = config
        @branch_id = @config[:branch_id] 
        @center_id = @config[:center_id] 
      end
      def execute!
        
        @rrest = RecomputeRestructure.new(
                               branch: @branch_id,
                               center: @center_id,
                               status: "pending"

                                          )
        @rrest.save!

        @rrest
        

        
      end

    end
  end
end
