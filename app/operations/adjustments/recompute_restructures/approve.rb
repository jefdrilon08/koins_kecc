module Adjustments
  module RecomputeRestructures
    class Approve
      def initialize(config:)
        @config = config
        @recompute_restructure_details =  @config[:recompute_restructure]
        @loan = Loan.find(@recompute_restructure_details.loan)
        
         
      end
      def execute!
      end
    end
  end
end
