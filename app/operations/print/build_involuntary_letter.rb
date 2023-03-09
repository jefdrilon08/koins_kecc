module Print
	class BuildInvoluntaryLetter
		def initialize(config)
			@config = config[:config]

			@member = Member.find(@config["member_id"])
			@loan_records = @config["loan_records"]
			@member_accounts = @config["member_accounts"]
			

			@member_data = @member.data.with_indifferent_access
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
				member_account: @member_accounts
			}
			@data
		end
	end
end