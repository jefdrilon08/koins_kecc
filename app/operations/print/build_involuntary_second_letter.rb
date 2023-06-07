module Print
	class BuildInvoluntarySecondLetter
		def initialize(config)
			@config = config[:config]
			@as_of = @config["as_of"]
			@member = Member.find(@config["member_id"])
			@loan_records = @config["loan_records"]
			@member_accounts = @config["member_accounts"]
			@member_data = @member.data.with_indifferent_access
		end 

		def execute!
		#	raise @member_accounts.inspect
			@last_savings_deposit = @member_accounts.sort_by{|key| key["last_transaction"] }.reverse.first
			
			@last_loan_payment = nil
			
			if @loan_records.present?
			 @loan_records.sort_by{|key| 
					if key["last_loan_payment"].present?
						@last_loan_payment = key["last_loan_payment"]
					end
					}.reverse.first
			end



			
			
			@total_loan_balance = 0
					@loan_records.each do |lr|
						principal_balance = lr["principal_balance"]
						interest_balance = lr["interest_balance"]
						@total_loan_balance += principal_balance.to_f + interest_balance.to_f
					end
					
			@data = {
				member_full_name: @member.first_name + " " + @member.middle_name + " " + @member.last_name,
				member_branch: @member.branch.name,
				member_center: @member.center.name,
				member_address: @member_data[:address][:street] + " "+@member_data[:address][:district]+ " "+ @member_data[:address][:city] + " "+ @member_data[:address][:region],
				total_loan_balance: @total_loan_balance.to_f.round(2),
				loan_records: @loan_records,
				member_account: @member_accounts,
				last_savings_deposit: @last_savings_deposit["last_transaction"],
				last_loan_payment_transaction: @last_loan_payment,
				as_of: @as_of.to_date + 30
			}


			@data
		end
	end
end