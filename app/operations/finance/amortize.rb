module Finance
  class Amortize
    N_YEARLY       = 1
    N_SEMI_ANNUALY = 2
    N_QUARTERLY    = 4
    N_MONTHLY      = 12
    N_SEMI_MONTHLY = 24
    N_WEEKLY       = 52
    N_DAILY        = 365

    TERMS = {
      "weekly"        => N_WEEKLY,
      "monthly"       => N_MONTHLY,
      "semi-monthly"  => N_SEMI_MONTHLY,
      "semi-annually" => N_SEMI_ANNUALY,
      "quarterly"     => N_QUARTERLY,
      "daily"         => N_DAILY,
    }

    def initialize(params:)
      Rails.logger.info("Amortizing loan with params #{params}")

      @principal            = params[:principal].to_f
      @annual_interest_rate = params[:annual_interest_rate]
      @num_installments     = params[:num_installments].to_i
      @term                 = params[:term]
      @n_mode               = TERMS.fetch(@term)
      @periodic_interest    = @annual_interest_rate / @n_mode

      if @annual_interest_rate > 0.00
        @emi  = ((@periodic_interest * @principal) / (1 - (1 + @periodic_interest)**(@num_installments * -1)))
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
          interest  = (@balance * @periodic_interest)
          principal = (@emi - interest)

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
            interest: interest.round(0),
            principal: principal,
            due: due
          }
        end
      end

      diff = (@total_principal - @principal).to_i
      if @total_principal > @principal
        @schedule.first[:principal] -= diff
        @schedule.first[:interest] += diff
      elsif @total_principal < @principal
        @schedule.first[:principal] += diff
        @schedule.first[:interest] -= diff
      end
      @total_principal += diff
      @total_interest -= diff

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
