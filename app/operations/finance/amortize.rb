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

      if positive_interest_rate?
        @periodic_interest = @annual_interest_rate / @n_mode
        @emi = ((@periodic_interest * @principal) / (1 - (1 + @periodic_interest)**(@num_installments * -1)))
      else
        @periodic_interest = 0
        @emi = 0
      end
    end

    def positive_interest_rate?
      @annual_interest_rate > 0.00
    end

    def execute!
      balance = @principal
      schedule = @num_installments.times.map do |i|
        if @emi == 0
          interest_paid  = 0.00
          principal_paid = balance / @num_installments
        else
          interest_paid  = balance * @periodic_interest
          principal_paid = @emi - interest_paid

          # Patch for negative values
          if interest_paid < 0
            interest_paid  = 0.00
            principal_paid = principal_paid - (interest_paid * -1)
          end
        end

        balance -= principal_paid

        {
          index:     i,
          interest:  interest_paid,
          principal: principal_paid,
          balance:   balance,
        }
      end

      #
      # Round off values
      #
      balance = @principal
      total_principal_diff = 0.00
      schedule = schedule.map do |s|
        interest_i  = s.fetch(:interest).round(0)
        principal_i = s.fetch(:principal).round(0)
        due         = principal_i + interest_i
        balance     -= principal_i

        principal_diff       = s.fetch(:principal) - principal_i
        total_principal_diff += principal_diff

        s.merge(
          num:       s[:index] + 1,
          interest:  interest_i,
          principal: principal_i,
          due:       due,
          balance:   balance,
        )
      end

      #
      # Use total difference to adjust first installment
      #
      total_principal_diff = total_principal_diff.round(0) # floating error
      puts "total_principal_diff: #{total_principal_diff}"
      if total_principal_diff.positive?
        schedule.first[:interest] -= total_principal_diff
        schedule.first[:principal] += total_principal_diff
      else
        schedule.first[:interest] -= total_principal_diff
        schedule.first[:principal] += total_principal_diff
      end

      #
      # Compute totals
      #
      total_interest  = schedule.pluck(:interest).sum
      total_principal = schedule.pluck(:principal).sum
      total_due       = schedule.pluck(:due).sum

      {
        schedule:          schedule,
        interest:          total_interest,
        principal:         total_principal,
        total_due:         total_due,
        periodic_interest: @periodic_interest.round(4),
        emi:               @emi.round(2)
      }
    end
  end
end
