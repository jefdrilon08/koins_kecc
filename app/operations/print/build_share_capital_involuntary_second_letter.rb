module Print
	class BuildShareCapitalInvoluntarySecondLetter
		def initialize(config)
			@config = config[:config]
			@member = Member.find(@config["member_id"])
			@member_data = @member.data.with_indifferent_access
			@as_of = @config["as_of"]
			@savings_accounts = @config["savings_accounts"]
			@loan_records     = @config["loan_records"]
			@insurance_account = @config["insurance_accounts"]
			@equity_accounts   = @config["equity_accounts"]
		end 

		def execute!

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
				savings_accounts: @savings_accounts,
				insurance_accounts: @insurance_account,
				equity_accounts: @equity_accounts,
					as_of: @as_of.to_date + 30
			}
			@data
		end
	end
end