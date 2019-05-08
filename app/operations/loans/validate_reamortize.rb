module Loans
  class ValidateReamortize < AppValidator
    def initialize(config:)
      super()
  
      @config                   = config
      @loan                     = @config[:loan]
      @p_principal              = @config[:p_principal]
      @p_monthly_interest_rate  = @config[:p_monthly_interest_rate]
      @p_annual_interest_rate   = (@p_monthly_interest_rate * 12)
      @p_num_installments       = @config[:p_num_installments]
      @p_term                   = @config[:p_term]

      @original_principal             = @loan.principal
      @original_monthly_interest_rate = @loan.monthly_interest_rate
      @original_num_installments      = @loan.num_installments
      @original_term                  = @loan.term
    end

    def execute!
      if @p_principal == @original_principal and @p_monthly_interest_rate == @original_monthly_interest_rate and @p_num_installments == @original_num_installments and @p_term == @original_term
        @errors[:messages] << {
          key: "parameters",
          message: "values are the same"
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
