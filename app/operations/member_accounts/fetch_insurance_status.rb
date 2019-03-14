module MemberAccounts
	class FetchInsuranceStatus
		def initialize(config:)
			@config = config

			@member_account   	= @config[:member_account]
			@member           	= @member_account.member
			@member_data      	= @member.data.with_indifferent_access
			@recognition_date  	= @member_data[:recognition_date].try(:to_date)
			@current_date     	= Date.today

			@account_transactions = AccountTransaction.personal_funds.where(
										"subsidiary_id = ?",
										@member_account.id
									).order("transacted_at ASC")

			if @recognition_date.nil?
				@recognition_date = @member.membership_payment_records.where(
										membership_type: "Insurance", 
										membership_name: "K-MBA"
									).first.try(:date_paid)
			end

			latest_transaction = @account_transactions.last
			@current_balance   = @member_account.balance

			@num_days = (@current_date - @recognition_date).to_i
			@num_weeks  = (@num_days / 7).to_i + 1
			
			@latest_transaction_date = latest_transaction.transacted_at

			@data = {
				recognition_date: @recognition_date.strftime("%B %d, %Y"),
				length_of_membership: @num_days,
				current_date: @current_date.strftime("%B %d, %Y"),
				latest_transaction_date: @latest_transaction_date.strftime("%B %d, %Y"),
				num_weeks: @num_weeks,
				current_balance: @current_balance
			}
		end

		def execute!
			if @member_account.account_subtype == "Retirement Fund"
				@data[:default_periodic_payment] = 5 
			elsif @member_account.account_subtype == "Life Insurance Fund"
				@data[:default_periodic_payment] = 15
			end

			@data[:coverage_date] 	= (@recognition_date + ((@current_balance / @data[:default_periodic_payment]).to_i).weeks).strftime("%B %d, %Y")
			@data[:insured_amount] 	= @num_weeks  * @data[:default_periodic_payment]
			@data[:amt_past_due]    = (@current_balance - @data[:insured_amount]) * -1
			@data[:num_weeks_past_due]  = (@data[:amt_past_due] / @data[:default_periodic_payment]).to_i

			@days_lapsed = (@current_date.to_date - @latest_transaction_date.to_date).to_i

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