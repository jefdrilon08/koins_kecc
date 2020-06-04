module MemberAccountValidations
	class AddMemberToMemberAccountValidation
		def initialize(config:)
      @config                               = config
      @user                                 = @config[:user]
      @member                               = @config[:member]
      @resignation_date                     = @config[:resignation_date]
      @member_classification                = @config[:member_classification]
      @member_account_validation            = @config[:member_account_validation]
      @equity_interest_implementation_date  = "2019-01-01".to_date
      @lif_50_percent                       = 0.00
      @advance_lif                          = 0.00
      @advance_rf                           = 0.00
      @total                                = 0.00

      @d = {}

      @lif_member_account   = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").first
      @rf_member_account    = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Retirement Fund").first
      @pl_member_account    = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Policy Loan").first
      
      @data                 = ::MemberAccountValidations::GenerateMemberAccountDetailsForLifAndRfForValidation.new(
                                member: @member, 
                                lif_member_account: @lif_member_account, 
                                rf_member_account: @rf_member_account, 
                                resignation_date: @resignation_date
                              ).execute!

      @equity_value         = @lif_member_account.data.with_indifferent_access[:equity_value] 

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
          # if @years >= 3
          #   if @lif_amount >= 2340
          #     @lif_50_percent = @lif_amount / 2
          #   end
          # end
          
          if @advance_lif > 0
            @lif_50_percent = (@equity_value - (@advance_lif / 2))
          else
            @lif_50_percent = @equity_value
          end

          # Old validation
          # @lif_50_percent   = @lif_amount / 2
        end
      
      if @years >= 1 && @rf_current_balance >= 260 
        @interest        = ::MemberAccountValidations::GenerateInterest.new(
                                          member_account: @rf_member_account,
                                          insured_amount: @rf_insured_amount,
                                          num_weeks: @rf_num_weeks,
                                          num_weeks_past_due: @rf_num_weeks_past_due
                                          ).execute!
        @interest_amount = @interest[:interest_table].last[:running_interest].to_f
      else
        @interest_amount = 0.00
      end

      # For equity interest
      w = ((@resignation_date.to_date - @equity_interest_implementation_date).to_i)/7
      if w >= 1
        @equity_interest        = ::MemberAccountValidations::GenerateEquityInterest.new(
                                          lif_member_account: @lif_member_account,
                                          resignation_date: @resignation_date,
                                          equity_interest_implementation_date: @equity_interest_implementation_date,
                                          lif_current_balance: @lif_current_balance
                                          ).execute!
        #@equity_interest_amount = (@equity_interest[:equity_interest].last[:running_interest].to_f + @equity_interest[:weekly_interest].last[:running_interest].to_f).round(2)
        @equity_interest_amount = @equity_interest[:equity_interest].last[:interest].to_f
      else
        @equity_interest_amount = 0.00
      end

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
      @d[:accounting_entry]  = ::MemberAccountValidations::BuildAccountingEntry.new(
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
                            }
   			)
   		@member_account_validation.member_account_validation_records << member_account_validation_record
    end
	end
end