module MemberAccountValidations
  class GenerateMemberAccountDetailsForLifAndRfForValidation
    def initialize(lif_member_account:, rf_member_account:, member:, resignation_date:)
      @lif_member_account     = lif_member_account
      @rf_member_account      = rf_member_account
      @member                 = member
      @data                   = {}
      @start_date             = @member.data.with_indifferent_access[:recognition_date].try(:to_date)
      #@current_date          = ApplicationHelper.current_working_date.to_date
      @current_date           = resignation_date.to_date

      if @start_date.nil?
        @start_date = @member.membership_payment_records.where(
                    membership_type: "Insurance", 
                    membership_name: "K-MBA"
                  ).first.try(:date_paid)
      end

      # Check
      if @start_date.blank?
        raise "No start date for member account #{@member.full_name}"
      end
    end

    def execute!
      build_lif_data!
      build_rf_data!
      @data
    end

    def build_lif_data!
      @lif_latest_payment             = AccountTransaction.personal_funds.where(
                                      "subsidiary_id = ?",@lif_member_account.id
                                      ).order("transacted_at ASC").last

      @lif_current_balance            = @lif_member_account.balance
      @lif_default_periodic_payment   = 15   
      @lif_num_days                   = (@current_date - @start_date).to_i
      @lif_num_weeks                  = (@lif_num_days / 7).to_i + 1
      @lif_insured_amount             = @lif_num_weeks * @lif_default_periodic_payment
      @lif_latest_transaction_date    = @lif_latest_payment.transacted_at
      @lif_num_days_insured           = (@lif_latest_transaction_date.to_date  - @start_date).to_i
      @lif_num_weeks_insured          = (@lif_num_days_insured / 7).to_i

      # @data[:lif_member_type]     = @lif_member_account.member_type.code
      # @data[:lif_member_type_id]  = @lif_member_account.member_type.id
      @data[:start_date]              = @start_date.strftime("%B %d, %Y")
      @data[:length_of_membership]    = (@current_date - @start_date).to_i
      @data[:current_date]            = @current_date.strftime("%B %d, %Y")
      @data[:lif_last_trans_date]     = @lif_latest_transaction_date.strftime("%B %d, %Y")
      @data[:lif_num_weeks]           = @lif_num_weeks
      @data[:lif_insured_amount]      = @lif_num_weeks  * @lif_default_periodic_payment
      @data[:lif_periodic_payment]    = @lif_default_periodic_payment
      @data[:lif_current_balance]     = @lif_current_balance
      @data[:lif_status]              = nil
      @data[:lif_coverage_date]       = (@start_date + ((@lif_current_balance / @lif_default_periodic_payment).to_i).weeks).strftime("%Y-%m-%d")
      @data[:lif_amt_past_due]        = (@lif_current_balance - @data[:lif_insured_amount]) * -1
      @data[:lif_num_weeks_past_due]  = (@data[:lif_amt_past_due] / @lif_default_periodic_payment).to_i

      @data
    end

    def build_rf_data!
      @rf_latest_payment              = AccountTransaction.personal_funds.where(
                                      "subsidiary_id = ?",@rf_member_account.id
                                      ).order("transacted_at ASC").last
      
      @rf_current_balance             = @rf_member_account.balance
      @rf_default_periodic_payment    = 5 
      @rf_num_days                    = (@current_date - @start_date).to_i
      @rf_num_weeks                   = (@rf_num_days / 7).to_i + 1
      @rf_insured_amount              = @rf_num_weeks * @rf_default_periodic_payment
      @rf_latest_transaction_date     = @rf_latest_payment.transacted_at
      @rf_num_days_insured            = (@rf_latest_transaction_date.to_date  - @start_date).to_i
      @rf_num_weeks_insured           = (@rf_num_days_insured / 7).to_i

      # @data[:rf_member_type]    = @rf_member_account.member_type.code
      # @data[:rf_member_type_id] = @rf_member_account.member_type.id
      @data[:start_date]              = @start_date.strftime("%B %d, %Y")
      @data[:length_of_membership]    = (@current_date - @start_date).to_i
      @data[:current_date]            = @current_date.strftime("%B %d, %Y")
      @data[:rf_last_trans_date]      = @rf_latest_transaction_date.strftime("%B %d, %Y")
      @data[:rf_num_weeks]            = @rf_num_weeks
      @data[:rf_insured_amount]       = @rf_num_weeks  * @rf_default_periodic_payment
      @data[:rf_periodic_payment]     = @rf_default_periodic_payment
      @data[:rf_current_balance]      = @rf_current_balance
      @data[:rf_status]               = nil
      @data[:rf_coverage_date]        = (@start_date + ((@rf_current_balance / @rf_default_periodic_payment).to_i).weeks).strftime("%Y-%m-%d")
      @data[:rf_amt_past_due]         = (@rf_current_balance - @data[:rf_insured_amount]) * -1
      @data[:rf_num_weeks_past_due]   = (@data[:rf_amt_past_due] / @rf_default_periodic_payment).to_i

      @data
    end
  end
end
