module Adjustments
  module AccruedInterest
    class Create
      def initialize(config:)
        @config = config
        @branch = @config[:branch]
        @center = @config[:center]
        @member = @confing[:member]
        @loans  = @confing[:loans]
          
        @cut_off_date         = @config[:cut_off_date]
        @start_date           = @config[:start_date]
        @end_date             = @config[:end_date]
        @number_of_days       = @config[:number_of_days]
        @number_of_moratorium = @config[:number_of_moratorium]
      end
      def execute!
      end
    end
  end
end
