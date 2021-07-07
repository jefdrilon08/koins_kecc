module Insurance
  class GenerateInsuranceAccountStatus
    def initialize(insurance_account:)
      @insurance_account  = insurance_account
      @member             = @insurance_account.member
      @data               = {}
      @start_date         = @member.data['recognition_date'].to_date
      @current_date       = Date.today

      
    end


    def execute!
      @account_transactions =  ReadOnlyAccountTransaction.where("subsidiary_id = ?", @insurance_account.id).order("transacted_at ASC")
      @latest_payment   = @account_transactions.last
      @current_balance  = @latest_payment ? @latest_payment.data['ending_balance'].to_i : 0.00

      if @insurance_account.account_subtype == "Retirement Fund"
        @data[:default_periodic_payment] = 5 
      elsif @insurance_account.account_subtype == "Life Insurance Fund"
        @data[:default_periodic_payment] = 15
      end

      @num_days   = (@current_date - @start_date).to_i
      @num_weeks  = (@num_days / 7).to_i + 1
      @insured_amount = (@num_weeks * @data[:default_periodic_payment]).to_i
      @latest_transaction_date  = @latest_payment ? @latest_payment.transacted_at.to_date : @start_date

      @num_days_insured   = (@latest_transaction_date.to_date  - @start_date).to_i
      @num_weeks_insured  = (@num_days_insured / 7).to_i

      @data[:start_date]            = @start_date.strftime("%B %d, %Y")
      #@data[:length_of_membership] = (@current_date - @start_date).to_i
      @data[:length_of_membership]  = @insurance_account.member.length_of_stay.titleize 
      @data[:current_date]          = @current_date.strftime("%B %d, %Y")
      @data[:last_trans_date]       = @latest_transaction_date.strftime("%B %d, %Y")
      @data[:num_weeks]             = @num_weeks
      @data[:insured_amount]        = @num_weeks  * @data[:default_periodic_payment]
      @data[:periodic_payment]      = @default_periodic_payment
      @data[:current_balance]       = @current_balance
      @data[:status]                = nil
      @data[:coverage_date]         = (@start_date + (@current_balance.to_i / @data[:default_periodic_payment].to_i).weeks).strftime("%B %d, %Y")
      @data[:amt_past_due]          = (@current_balance - @data[:insured_amount]) * -1
      @data[:num_weeks_past_due]    = (@data[:amt_past_due] / @data[:default_periodic_payment]).to_i

      @days_lapsed = (@current_date - @latest_transaction_date).to_i

      if @days_lapsed <= 45 && @current_balance > @data[:insured_amount]
        @data[:status] = "advanced"
      elsif @days_lapsed >= 45 && @current_balance > @data[:insured_amount]
        @data[:status] = "advanced"
      elsif @days_lapsed > 45 && @current_balance < @data[:insured_amount]
        @data[:status]  = "lapsed"
      elsif @days_lapsed <= 45 && @current_balance < @data[:insured_amount] && @data[:amt_past_due] >= 97
        @data[:status]  = "lapsed"  
      elsif @days_lapsed <= 45 && @current_balance < @data[:insured_amount] && @data[:amt_past_due] < 97
        @data[:status]  = "past due"  
      else
        @data[:status] = "normal"
      end

      @data
    end
  end
end
