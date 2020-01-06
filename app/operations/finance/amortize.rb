module Finance
  class Amortize
    N_YEARLY        = 1 
    N_SEMI_ANNUALY  = 2 
    N_QUARTERLY     = 4 
    N_MONTHLY       = 12
    N_SEMI_MONTHLY  = 24
    N_WEEKLY        = 52
    N_DAILY         = 365 

    TERMS = ["weekly", "monthly", "semi-monthly", "semi-annually", "quarterly", "daily"]

    def initialize(params:)
      @params = params
      
      @principal            = @params[:principal].to_f
      @annual_interest_rate = @params[:annual_interest_rate]
      @num_installments     = @params[:num_installments].to_i
      @term                 = @params[:term]

      Rails.logger.info("Amortizing loan with params #{@params}")
      case @term
      when "yearly"
        @n_mode             = ::Finance::Amortize::N_YEARLY
        @periodic_interest  = @annual_interest_rate / @n_mode
      when "quarterly"
        @n_mode             = ::Finance::Amortize::N_QUARTERLY
        @periodic_interest  = @annual_interest_rate / @n_mode
      when "monthly"
        @n_mode             = ::Finance::Amortize::N_MONTHLY
        @periodic_interest  = @annual_interest_rate / @n_mode
      when "semi-monthly"
        @n_mode             = ::Finance::Amortize::N_SEMI_MONTHLY
        @periodic_interest  = @annual_interest_rate / @n_mode
      when "weekly"
        @n_mode             = ::Finance::Amortize::N_WEEKLY
        @periodic_interest  = @annual_interest_rate / @n_mode
      when "daily"
        @n_mode             = ::Finance::Amortize::N_DAILY
        @periodic_interest  = @annual_interest_rate / @n_mode
      else
        raise "Unsupported term #{@term}"
      end

      if @annual_interest_rate > 0.00
        @emi  = ((@periodic_interest * @principal) / (1 - (1 + @periodic_interest)**(@num_installments * -1))).round(0)
      else
        @emi  = 0
        @periodic_interest  = 0
      end

      @schedule = []
    end

    def execute!
      @balance  = @principal

      @total_interest   = 0.00
      @total_principal  = 0.00

      if @emi == 0
        periodic_payment  = @balance / @num_installments

        @num_installments.times do |i|
          interest  = 0.00
          principal = periodic_payment

          due = principal

          @total_principal += principal

          @balance -= principal

          @schedule << {
            index: i,
            num: i+1,
            interest: interest,
            principal: principal,
            due: due
          }
        end
      else
        @num_installments.times do |i|
          interest  = (@balance * @periodic_interest).round(0)
          principal = (@emi - interest).round(0)

          # Patch for negative values
          if interest < 0
            diff      = interest * -1
            interest  = 0.00
            principal -= diff
          end

          due       = (principal + interest)

          @total_interest   += interest
          @total_principal  += principal

          @balance -= principal

          @schedule << {
            index: i,
            num: i+1,
            interest: interest,
            principal: principal,
            due: due
          }
        end
      end

      if @total_principal > @principal
        diff = @total_principal - @principal

        @schedule.first[:principal] -= diff
        @schedule.first[:interest] += diff

        @total_principal -= diff
        @total_interest += diff
      elsif @total_principal < @principal
        diff = @principal - @total_principal

        @schedule.first[:principal] += diff
        @schedule.first[:interest] -= diff

        @total_principal += diff
        @total_interest -= diff
      end

      total_due         = @total_principal + @total_interest
      periodic_payment  = @emi

      return {
        schedule: @schedule,
        principal: @total_principal,
        interest: @total_interest,
        total_due: total_due,
        periodic_interest: @periodic_interest.round(4),
        emi: @emi
      }
    end
  end
end
