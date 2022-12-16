module Insurance
  class GenerateInsuranceAccountDetailsForLifAndRf
    def initialize(config:)
      @config                 = config
      @lif_insurance_account  = @config[:lif_insurance_account]
      @rf_insurance_account   = @config[:rf_insurance_account]
      @member                 = @config[:member] 
      @start_date             = @member.data['recognition_date'].to_date
      @current_date           = @config[:date_of_death]
      @account_transactions   = ReadOnlyAccountTransaction.where("subsidiary_id IN (?) AND transacted_at <= ?", [@lif_insurance_account.id, @rf_insurance_account.id], @current_date)
      @account_transactions_rf   = ReadOnlyAccountTransaction.where("subsidiary_id = ? ", @rf_insurance_account.id)
      @data                   = {}
    end
    
    def execute!
      build_lif_data!
      build_rf_data!
      @data
    end

    def build_lif_data!
      @life_account_transaction = @account_transactions.where(subsidiary_id: @lif_insurance_account.id).order("created_at ASC")
      @life_latest_payment      = @life_account_transaction.last
      @life_current_balance     = @life_latest_payment.data.with_indifferent_access[:ending_balance].to_f
            
      @life_num_days   = (@current_date - @start_date).to_i
      @life_num_weeks  = (@life_num_days / 7).to_i + 1
      @life_insured_amount = @life_num_weeks * 15
      @life_latest_transaction_date  = @life_latest_payment ? @life_latest_payment.transacted_at.to_date : @start_date

      @life_num_days_insured   = (@life_latest_transaction_date - @start_date).to_i
      @life_num_weeks_insured  = (@life_num_days_insured / 7).to_i

      @data[:start_date]              = @start_date.strftime("%B %d, %Y")
      @data[:current_date]            = @current_date.strftime("%B %d, %Y")
      @data[:life_last_trans_date]     = @life_latest_transaction_date.strftime("%B %d, %Y")
      @data[:life_num_weeks]           = @life_num_weeks
      @data[:life_insured_amount]      = @life_num_weeks  * 15
      @data[:life_current_balance]     = @life_current_balance
      @data[:life_coverage_date]       = (@start_date + 38.days + (@life_current_balance.to_i / 15).weeks).strftime("%Y-%m-%d")
      @data[:life_amt_past_due]        = (@life_current_balance - @data[:life_insured_amount]).to_i * -1
      @data[:life_num_weeks_past_due]  = (@data[:life_amt_past_due] / 15).to_i

      @data
    end

    def build_rf_data!
      @rf_account_transaction   = @account_transactions.where(subsidiary_id: @rf_insurance_account.id).order("created_at ASC")
      @rf_latest_payment        = @rf_account_transaction.last
      @rf_current_balance       = @rf_latest_payment.data.with_indifferent_access[:ending_balance].to_f
      
      #added for RF Only Computation
      @member_accounts                   = ReadOnlyMemberAccount.where(" account_type = ? AND account_subtype = (?) ", "INSURANCE",  "Retirement Fund")
      @rf                                = @member_accounts.first
      @rf_account_transaction_deposit    = @account_transactions_rf.where("transaction_type = ?", "deposit").sum(:amount).to_f
      @rf_account_transaction_withdraw   = @account_transactions_rf.where("transaction_type = ?", "withdraw").sum(:amount).to_f
      @rf_account_transaction_interest   = @account_transactions_rf.where("transaction_type = ? AND data->>'is_interest' = ?", "deposit","true").sum(:amount).to_f
      @rf_account_only     = (@rf_account_transaction_deposit - @rf_account_transaction_withdraw - @rf_account_transaction_interest).to_f

      @rf_num_days   = (@current_date - @start_date).to_i
      @rf_num_weeks  = (@rf_num_days / 7).to_i + 1
      @rf_insured_amount = @rf_num_weeks * 5
      @rf_latest_transaction_date  = @rf_latest_payment ? @rf_latest_payment.transacted_at.to_date : @start_date
      @rf_num_days_insured   = (@rf_latest_transaction_date  - @start_date).to_i
      @rf_num_weeks_insured  = (@rf_num_days_insured / 7).to_i

      @data[:start_date]             = @start_date.strftime("%B %d, %Y")
      @data[:current_date]           = @current_date.strftime("%B %d, %Y")
      @data[:rf_last_trans_date]     = @rf_latest_transaction_date.strftime("%B %d, %Y")
      @data[:rf_num_weeks]           = @rf_num_weeks
      @data[:rf_insured_amount]      = @rf_num_weeks  * 5
      @data[:rf_current_balance]     = @rf_current_balance
      #@data[:rf_coverage_date]       = (@start_date + 38.days + (@rf_current_balance.to_i / 5).weeks).strftime("%Y-%m-%d")
      @data[:rf_coverage_date]       = (@start_date + 45.days + (@rf_account_only.to_i / 5).weeks).strftime("%Y-%m-%d")
      #@data[:rf_amt_past_due]        = (@rf_current_balance - @data[:rf_insured_amount]).to_i * -1
      @data[:rf_amt_past_due]        = (@rf_account_only - @data[:rf_insured_amount]).to_i * -1
      @data[:rf_num_weeks_past_due]  = (@data[:rf_amt_past_due] / 5).to_i
      #added for RF Only Computation
      @data[:rf_account_only]        = @rf_account_only
      @data
    end
  end
end
