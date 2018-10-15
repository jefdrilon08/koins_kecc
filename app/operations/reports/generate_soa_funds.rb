module Reports
  class GenerateSoaFunds
    def initialize(config:)
      @config = config

      @branch   = @config[:branch]
      @centers  = @branch.centers

      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]

      @dates  = (@start_date..@end_date).map{ |o| o }

      @account_transactions = AccountTransaction

      @data = {
        start_date: @start_date,
        end_date: @end_date
      }
    end

    def execute!
    end
  end
end
