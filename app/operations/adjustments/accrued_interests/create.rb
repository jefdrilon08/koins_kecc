module Adjustments
  module AccruedInterest
    class Create
      def initialize(config)
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
        @loans.each do |loans|
            amortization_principal_balance = AmortizationScheduleEntry.where(
                                                                    "loan_id = ? and
                                                                     due_date >= ? and
                                                                     due_date <= ? and
                                                                     is_paid is null
                                                                    
                                                                    "
                                                                    loans.id,
                                                                    @start_date,
                                                                    @end_date
                                                                    ).order(:due_date).sum(:principal)

            accrued_interest = ((amortization_principal_balance * loans.monthly_interest_rate) * @number_of_days) / 100
        end
      end
    end
  end
end
