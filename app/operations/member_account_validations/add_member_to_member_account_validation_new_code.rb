module MemberAccountValidations
	class AddMemberToMemberAccountValidationNewCode
		def initialize(config:)
      @config                               = config
      @user                                 = @config[:user]
      @member                               = @config[:member]
      @resignation_date                     = @config[:resignation_date]
      @member_classification                = @config[:member_classification]
      @member_account_validation            = @config[:member_account_validation]
      @date_restored                        = @member.interest_start_date.try(:to_date)
      @equity_interest_implementation_date  = "2019-01-01".to_date
      @interest_starting_date               = "2021-09-15".to_date
      @lif_50_percent                       = 0.00
      @advance_lif                          = 0.00
      @advance_rf                           = 0.00
      @total                                = 0.00

      @d = {}

      @lif_member_account   = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").first
      @rf_member_account    = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Retirement Fund").first
      @pl_member_account    = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Policy Loan").first
      @ev_member_account    = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Equity Value").first     
      
      if @date_restored.present?
        @interest_amount        = @rf_member_account.account_transactions.where("status = ? AND data->>'is_interest' = ? AND transacted_at >= ?", "approved", "true", @date_restored).sum(:amount).to_f
        @equity_interest_amount = @ev_member_account.account_transactions.where("status = ? AND data->>'is_interest' = ? AND transacted_at >= ?", "approved", "true", @date_restored).sum(:amount).to_f
    
        @data                 = ::MemberAccountValidations::GenerateMemberAccountDetailsForLifAndRfForValidation.new(
                               member: @member, 
                               lif_member_account: @lif_member_account, 
                               rf_member_account: @rf_member_account, 
                               resignation_date: @resignation_date,
                               rf_interest_amount: @interest_amount
                             ).execute!
        
        # @equity_value         = @ev_member_account.try(:balance).to_f
        @equity_value         = @lif_member_account.try(:balance).to_f / 2 
      else
        @interest_amount = @rf_member_account.account_transactions.where("status = ? AND data->>'is_interest' = ? AND transacted_at >= ?", "approved", "true", @interest_starting_date).sum(:amount).to_f  
        @equity_interest_amount = @ev_member_account.account_transactions.where("status = ? AND data->>'is_interest' = ? AND transacted_at >= ?", "approved", "true", @interest_starting_date).sum(:amount).to_f

        @data                 = ::MemberAccountValidations::GenerateMemberAccountDetailsForLifAndRfForValidation.new(
                                  member: @member, 
                                  lif_member_account: @lif_member_account, 
                                  rf_member_account: @rf_member_account, 
                                  resignation_date: @resignation_date,
                                  rf_interest_amount: @interest_amount
                                ).execute!

        # @equity_value         = @ev_member_account.try(:balance).to_f
        @equity_value         = @lif_member_account.try(:balance).to_f / 2 
      end
      if !@pl_member_account.nil?
        @policy_loan = @pl_member_account.try(:balance).to_f
      else
        @policy_loan = 0.00
      end

      @lif_current_balance        = @data[:lif_current_balance]
      @rf_current_balance         = @data[:rf_current_balance]
      @lif_amt_past_due           = @data[:lif_amt_past_due]
      @rf_amt_past_due            = @data[:rf_amt_past_due]
      @lif_num_weeks_past_due     = @data[:lif_num_weeks_past_due]
      @rf_num_weeks_past_due      = @data[:rf_num_weeks_past_due]
      #@lif_insured_amount         = @data[:lif_insured_amount]
      @rf_insured_amount          = @data[:rf_insured_amount]
      @rf_num_weeks               = @data[:rf_num_weeks]
      #@number_of_days_lapsed      = @rf_num_weeks_past_due * 7

      # Check if member has advance, lapsed and normal payment
      if @lif_num_weeks_past_due < 0 && @rf_num_weeks_past_due < 0
        @rf_amount    = @rf_current_balance - (@rf_amt_past_due * -1)
        @lif_amount   = @lif_current_balance - (@lif_amt_past_due * -1) 
        @advance_rf   = @rf_amt_past_due * -1
        @advance_lif  = @lif_amt_past_due * -1
      elsif @lif_num_weeks_past_due < 0 && @rf_num_weeks_past_due > 0
        @rf_amount    = @rf_current_balance
        @lif_amount   = @lif_current_balance - (@lif_amt_past_due * -1) 
        @advance_rf   = @rf_amt_past_due * 0
        @advance_lif  = @lif_amt_past_due * -1
      elsif @lif_num_weeks_past_due < 0 && @rf_num_weeks_past_due == 0
        @rf_amount    = @rf_current_balance
        @lif_amount   = @lif_current_balance - (@lif_amt_past_due * -1) 
        @advance_lif  = @lif_amt_past_due * -1  
      elsif @lif_num_weeks_past_due == 0 && @rf_num_weeks_past_due > 0
        @rf_amount    = @rf_current_balance
        @lif_amount   = @lif_current_balance - (@lif_amt_past_due * -1) 
        @advance_rf   = @rf_amt_past_due * 0
      elsif @lif_num_weeks_past_due == 0 && @rf_num_weeks_past_due == 0
        @rf_amount    = @rf_current_balance
        @lif_amount   = @lif_current_balance
      elsif @lif_num_weeks_past_due > 0 && @rf_num_weeks_past_due > 0
        @rf_amount    = @rf_current_balance
        @lif_amount   = @lif_current_balance
      else
        @rf_amount    = @rf_current_balance
        @lif_amount   = @lif_current_balance
      end   

      # Check if member is 3 years above in KMBA
      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @member_account_validation.branch
                        }
                      ).execute!

      @recognition_date = @member.data.with_indifferent_access[:recognition_date].try(:to_date)
      
      if !@recognition_date.nil?  
        @seconds_between  = (@current_date.to_time - @recognition_date.to_time).abs
        @days_between     = @seconds_between / 60 / 60 / 24
        @number_of_months = (@days_between / 30.44).floor
        @years            = (@days_between / 365.242199).floor
        @months           = @number_of_months - (@years * 12)
        
        if @advance_lif > 0
          ev_less_interest = @equity_value - @equity_interest_amount
          # @lif_50_percent = (ev_less_interest - (@advance_lif / 2))
          @lif_50_percent = (@equity_value - (@advance_lif / 2))
        else
          # @lif_50_percent = @equity_value - @equity_interest_amount
          @lif_50_percent = @equity_value 
        end
      end

      # if @interest_amount > 0.00
      #   if @advance_rf > 0.00
      #     @advance_rf = @advance_rf - @interest_amount
      #   elsif @advance_rf <= 0.00 && @rf_amount > 0.00
      #     @rf_amount = @rf_amount - @interest_amount
      #   end
      # end

      @total = (@lif_50_percent + @rf_amount + @advance_lif + @advance_rf + @interest_amount + @equity_interest_amount).round(2)

      if !@pl_member_account.nil?
        if @policy_loan > 0
          @total = (@total - @policy_loan).round(2)
        end
      end

      @member_account_validation
    end

    def execute!
      build_member_account_validation_record!

      # Update accounting_entry
      @d[:accounting_entry]  = ::MemberAccountValidations::BuildAccountingEntryNewCode.new(
                                    config: {
                                      branch: @member_account_validation.branch,
                                      member_account_validation: @member_account_validation,
                                      is_remote: @member_account_validation.is_remote,
                                      user: @user
                                    }
                                  ).execute!

      @member_account_validation.data = @d

      @member_account_validation.save!

      @member_account_validation
    end

    private

   	def build_member_account_validation_record!
   		member_account_validation_record = MemberAccountValidationRecord.new(
   													member: @member,
                            center: @member.center,
                            transaction_number: "",
                            lif_50_percent: @lif_50_percent,
                            resignation_date: @resignation_date,
                            member_classification: @member_classification,
                            rf: @rf_amount,
                            advance_lif: @advance_lif,
                            advance_rf: @advance_rf,
                            interest: @interest_amount,
                            total: @total,
                            equity_interest: @equity_interest_amount,
                            equity_value: @equity_value,
                            policy_loan: @policy_loan,
                            data: {
                              is_void: false,
                              member_type: @member.member_type,
                              insurance_status: @member.insurance_status,
                            }
   			)
   		@member_account_validation.member_account_validation_records << member_account_validation_record
    end
	end
end