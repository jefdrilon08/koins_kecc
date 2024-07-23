module MemberAccounts
	class FetchInsuranceStatus
		def initialize(config:)
			@config = config

			@member_account   	= @config[:member_account]
			@member           	= @member_account.member
			@status 			= @member.status
	      	@member_type 		= @member.member_type
	      	@insurance_status	= @member.insurance_status


	      	# raise @status.inspect
			@member_data      					= @member.data.with_indifferent_access

			# raise @member_data.inspect
		
			
			if @member_data[:reinstatement].present?
				@data_reinstatement_date		= @member_data[:reinstatement][:reinstatement_date].try(:to_date)
				@data_date_stop  				= @member_data[:reinstatement][:date_stop].try(:to_date)
				@data_old_recognition_date  	= @member_data[:reinstatement][:old_recognition_date].try(:to_date)
				@current_date     				= Date.today
				@recognition_date  				= @member_data[:recognition_date].try(:to_date)
				@reinstatement_date             = ((@current_date - @data_reinstatement_date) + (@data_date_stop - @data_old_recognition_date)).try(:to_date)

				# raise @reinstatement_date.inspect
			else
				@current_date     				= Date.today
				@recognition_date  				= @member_data[:recognition_date].try(:to_date)
			end


			@account_transactions = AccountTransaction.personal_funds.where(
										"subsidiary_id = ?",
										@member_account.id
									).order("transacted_at ASC")

			if @recognition_date.nil?
				@recognition_date = @member.membership_payment_records.where(
										membership_type: ["Insurance", "Cooperative"],
										membership_name: ["K-MBA", "K-KOOP"]
									).first.try(:date_paid)
			end

			latest_transaction = @account_transactions.last
			@current_balance   = @member_account.balance
			
			if @data_reinstatement_date.present?
				@num_days = ((@current_date - @data_reinstatement_date).to_i ) 
			else	
				@num_days = (@current_date - @recognition_date).to_i
			end

			@num_weeks  = (@num_days / 7).to_i + 1

			# raise @num_weeks.inspect

			@latest_transaction_date = latest_transaction.try(:transacted_at)

			@data = {
				recognition_date: @recognition_date.strftime("%B %d, %Y"),
				length_of_membership: @member.length_of_stay.try(:titleize),
				current_date: @current_date.strftime("%B %d, %Y"),
				latest_transaction_date: @latest_transaction_date.try(:strftime, "%B %d, %Y"),
				num_weeks: @num_weeks,
				current_balance: @current_balance
			}
		end

		def execute!
			if @member_account.account_subtype == "Retirement Fund"
				@data[:default_periodic_payment] = 5 
			elsif @member_account.account_subtype == "Life Insurance Fund"
				@data[:default_periodic_payment] = 15
			elsif @member_account.account_subtype == "K-BENTE"
				@data[:default_periodic_payment] = 20 
			elsif @member_account.account_subtype == "K-KALINGA"
				@data[:default_periodic_payment] = 50
			end

			if @data_reinstatement_date.present?
				# puts " reinstatement date: #{@reinstatement_date}"
				@data[:coverage_date] 		= (@data_reinstatement_date + ((@current_balance / @data[:default_periodic_payment]) * 7).to_i).strftime("%B %d, %Y")
				@data[:insured_amount] 		= @num_weeks  * @data[:default_periodic_payment]
				@data[:amt_past_due]    	= (@current_balance - @data[:insured_amount]) * -1
				@data[:num_weeks_past_due]  = (@data[:amt_past_due] / @data[:default_periodic_payment]).to_i

				@amount_past_due = @data[:amt_past_due].to_i
				if @latest_transaction_date.present?
	        		@days_lapsed = (@current_date.to_date - @latest_transaction_date.to_date).to_i

	      		else
	        		@days_lapsed  = 999
	      		end
			else
				# puts " recognition_date: #{@recognition_date}"
				@data[:coverage_date] 		= (@recognition_date + ((@current_balance / @data[:default_periodic_payment]).to_i).weeks).strftime("%B %d, %Y")
				@data[:insured_amount] 		= @num_weeks  * @data[:default_periodic_payment]
				@data[:amt_past_due]    	= (@current_balance - @data[:insured_amount]) * -1
				@data[:num_weeks_past_due]  = (@data[:amt_past_due] / @data[:default_periodic_payment]).to_i
				
				@amount_past_due = @data[:amt_past_due].to_i
				if @latest_transaction_date.present?
	        		@days_lapsed = (@current_date.to_date - @latest_transaction_date.to_date).to_i
	      		else
	        		@days_lapsed  = 999
	      		end
			end
			
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




