module Insurance
  class GenerateInsuranceAccountDetailsForLifAndRf
    def initialize(lif_insurance_account:, rf_insurance_account:, member:)
      @lif_insurance_account  = lif_insurance_account
      @rf_insurance_account  = rf_insurance_account
      @member             = member
      @data               = {}
      @start_date         = @member.data['recognition_date'].to_date
      @current_date       = Date.today
      
    end
    
    def execute!
      build_lif_data!
      build_rf_data!
      @data
      
    end

    def build_lif_data!
      @account_transaction =  AccountTransaction.where("subsidiary_id = ?", @lif_insurance_account.id).order("transacted_at ASC")
      @lif_latest_payment   = @account_transaction.last
      @lif_current_balance  = @lif_latest_payment ? @lif_latest_payment.data['ending_balance'].to_i : 0.00
 
      @lif_default_periodic_payment = 15
            

      @lif_num_days   = (@current_date - @start_date).to_i
      # @num_weeks  = (@num_days / 7).to_i
      @lif_num_weeks  = (@lif_num_days / 7).to_i + 1
      @lif_insured_amount = @lif_num_weeks * @lif_default_periodic_payment.to_i
      @lif_latest_transaction_date  = @lif_latest_payment ? @lif_latest_payment.transacted_at.to_date : @start_date

      @lif_num_days_insured   = (@lif_latest_transaction_date - @start_date).to_i
      @lif_num_weeks_insured  = (@lif_num_days_insured / 7).to_i

      @data[:start_date]        = @start_date.strftime("%B %d, %Y")
      @data[:length_of_membership]  = (@current_date - @start_date).to_i
      @data[:current_date]      = @current_date.strftime("%B %d, %Y")
      @data[:lif_last_trans_date]   = @lif_latest_transaction_date.strftime("%B %d, %Y")
      @data[:lif_num_weeks]         = @lif_num_weeks
      @data[:lif_insured_amount]    = @lif_num_weeks  * @lif_default_periodic_payment
      @data[:lif_periodic_payment]  = @lif_default_periodic_payment
      @data[:lif_current_balance]   = @lif_current_balance
      @data[:lif_status]            = nil
      @data[:lif_coverage_date]     = (@start_date + (@lif_current_balance.to_i / @lif_default_periodic_payment.to_i).weeks).strftime("%Y-%m-%d")
      @data[:lif_amt_past_due]      = (@lif_current_balance - @data[:lif_insured_amount]).to_i * -1
      @data[:lif_num_weeks_past_due]  = (@data[:lif_amt_past_due] / @lif_default_periodic_payment).to_i


      if @lif_current_balance.to_i > @data[:lif_insured_amount].to_i
        @data[:lif_status] = "advanced"
      elsif @lif_current_balance.to_i < @data[:lif_insured_amount].to_i
        @data[:lif_status]  = "past due"
      else
        @data[:lif_status] = "normal"
      end

      @data
    end

    def build_rf_data!
      @account_transaction   = AccountTransaction.where("subsidiary_id = ?", @rf_insurance_account.id).order("transacted_at ASC")
      @rf_latest_payment   = @account_transaction.last
      @rf_current_balance  = @rf_latest_payment ? @rf_latest_payment.data['ending_balance'].to_i : 0.00

      @rf_default_periodic_payment = 5

      @rf_num_days   = (@current_date - @start_date).to_i
      # @num_weeks  = (@num_days / 7).to_i
      @rf_num_weeks  = (@rf_num_days / 7).to_i + 1
      @rf_insured_amount = @rf_num_weeks * @rf_default_periodic_payment
      @rf_latest_transaction_date  = @rf_latest_payment ? @rf_latest_payment.transacted_at.to_date : @start_date

      @rf_num_days_insured   = (@rf_latest_transaction_date  - @start_date).to_i
      @rf_num_weeks_insured  = (@rf_num_days_insured / 7).to_i

      @data[:start_date]        = @start_date.strftime("%B %d, %Y")
      @data[:length_of_membership]  = (@current_date - @start_date).to_i
      @data[:current_date]      = @current_date.strftime("%B %d, %Y")
      @data[:rf_last_trans_date]   = @rf_latest_transaction_date.strftime("%B %d, %Y")
      @data[:rf_num_weeks]         = @rf_num_weeks
      @data[:rf_insured_amount]    = @rf_num_weeks  * @rf_default_periodic_payment
      @data[:rf_periodic_payment]  = @rf_default_periodic_payment
      @data[:rf_current_balance]   = @rf_current_balance
      @data[:rf_status]            = nil
      @data[:rf_coverage_date]     = (@start_date + (@rf_current_balance.to_i / @rf_default_periodic_payment  .to_i).weeks).strftime("%Y-%m-%d")
      @data[:rf_amt_past_due]      = (@rf_current_balance - @data[:rf_insured_amount]).to_i * -1
      @data[:rf_num_weeks_past_due]  = (@data[:rf_amt_past_due] / @rf_default_periodic_payment).to_i


      if @rf_current_balance.to_i > @data[:rf_insured_amount].to_i
        @data[:rf_status] = "advanced"
      elsif @rf_current_balance.to_i < @data[:rf_insured_amount].to_i
        @data[:rf_status]  = "past due"
      else
        @data[:rf_status] = "normal"
      end

      @data
    end
  end
end
