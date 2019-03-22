module MemberAccountValidation
  class GenerateMemberAccountDetailsForLifAndRfForValidation
    def initialize(lif_insurance_account:, rf_insurance_account:, member:, resignation_date:)
      @lif_insurance_account  = lif_insurance_account
      @rf_insurance_account   = rf_insurance_account
      @member                 = member
      @data                   = {}
      @start_date             = @member.data[:reconition_date]
      #@current_date          = ApplicationHelper.current_working_date.to_date
      @current_date           = resignation_date.to_date

      if @start_date.blank?
        insurance_membership_type_name = "KMB-A"
        @member.memberships.each do |membership|
          if membership[:membership_type][:name] == insurance_membership_type_name
            @start_date = membership[:membership_payment][:paid_at].try(:to_date)
          end
        end
      end

      # @latest_payment   = @insurance_account.insurance_account_transactions.last
      # @current_balance  = @latest_payment ? @latest_payment.ending_balance : 0.00

      # @default_periodic_payment = @insurance_account.insurance_type.default_periodic_payment

      # Check
      if @start_date.blank?
        raise "No start date for insurance account #{@insurance_account.id}"
      end
    end

    def execute!
      build_lif_data!
      build_rf_data!
      @data
    end

    def build_lif_data!
      @lif_latest_payment   = @lif_insurance_account.insurance_account_transactions.last
      @lif_current_balance  = @lif_latest_payment ? @lif_latest_payment.ending_balance : 0.00

      @lif_default_periodic_payment = @lif_insurance_account.insurance_type.default_periodic_payment

      @lif_num_days   = (@current_date - @start_date).to_i
      # @num_weeks  = (@num_days / 7).to_i
      @lif_num_weeks  = (@lif_num_days / 7).to_i + 1
      @lif_insured_amount = @lif_num_weeks * @lif_default_periodic_payment
      @lif_latest_transaction_date  = @lif_latest_payment ? @lif_latest_payment.transacted_at.to_date : @start_date

      @lif_num_days_insured   = (@lif_latest_transaction_date.to_date  - @start_date).to_i
      @lif_num_weeks_insured  = (@lif_num_days_insured / 7).to_i

      @data[:lif_insurance_type]    = @lif_insurance_account.insurance_type.code
      @data[:lif_insurance_type_id] = @lif_insurance_account.insurance_type.id
      @data[:start_date]        = @start_date.strftime("%B %d, %Y")
      @data[:length_of_membership]  = (@current_date - @start_date).to_i
      @data[:current_date]      = @current_date.strftime("%B %d, %Y")
      @data[:lif_last_trans_date]   = @lif_latest_transaction_date.strftime("%B %d, %Y")
      @data[:lif_num_weeks]         = @lif_num_weeks
      @data[:lif_insured_amount]    = @lif_num_weeks  * @lif_default_periodic_payment
      @data[:lif_periodic_payment]  = @lif_default_periodic_payment
      @data[:lif_current_balance]   = @lif_current_balance
      @data[:lif_status]            = nil
      @data[:lif_coverage_date]     = (@start_date + ((@lif_current_balance / @lif_default_periodic_payment).to_i).weeks).strftime("%Y-%m-%d")
      @data[:lif_amt_past_due]      = (@lif_current_balance - @data[:lif_insured_amount]) * -1
      @data[:lif_num_weeks_past_due]  = (@data[:lif_amt_past_due] / @lif_default_periodic_payment).to_i

      @data
    end

    def build_rf_data!
      @rf_latest_payment   = @rf_insurance_account.insurance_account_transactions.last
      @rf_current_balance  = @rf_latest_payment ? @rf_latest_payment.ending_balance : 0.00

      @rf_default_periodic_payment = @rf_insurance_account.insurance_type.default_periodic_payment

      @rf_num_days   = (@current_date - @start_date).to_i
      # @num_weeks  = (@num_days / 7).to_i
      @rf_num_weeks  = (@rf_num_days / 7).to_i + 1
      @rf_insured_amount = @rf_num_weeks * @rf_default_periodic_payment
      @rf_latest_transaction_date  = @rf_latest_payment ? @rf_latest_payment.transacted_at.to_date : @start_date

      @rf_num_days_insured   = (@rf_latest_transaction_date.to_date  - @start_date).to_i
      @rf_num_weeks_insured  = (@rf_num_days_insured / 7).to_i

      @data[:rf_insurance_type]    = @rf_insurance_account.insurance_type.code
      @data[:rf_insurance_type_id] = @rf_insurance_account.insurance_type.id
      @data[:start_date]        = @start_date.strftime("%B %d, %Y")
      @data[:length_of_membership]  = (@current_date - @start_date).to_i
      @data[:current_date]      = @current_date.strftime("%B %d, %Y")
      @data[:rf_last_trans_date]   = @rf_latest_transaction_date.strftime("%B %d, %Y")
      @data[:rf_num_weeks]         = @rf_num_weeks
      @data[:rf_insured_amount]    = @rf_num_weeks  * @rf_default_periodic_payment
      @data[:rf_periodic_payment]  = @rf_default_periodic_payment
      @data[:rf_current_balance]   = @rf_current_balance
      @data[:rf_status]            = nil
      @data[:rf_coverage_date]     = (@start_date + ((@rf_current_balance / @rf_default_periodic_payment).to_i).weeks).strftime("%Y-%m-%d")
      @data[:rf_amt_past_due]      = (@rf_current_balance - @data[:rf_insured_amount]) * -1
      @data[:rf_num_weeks_past_due]  = (@data[:rf_amt_past_due] / @rf_default_periodic_payment).to_i

      @data
    end
  end
end
