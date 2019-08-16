module MemberAccounts
	class FetchMembersFromTransactions
		def initialize(config:)
			@config	= config

			@start_date			= @config[:start_date]
			@end_date			= @config[:end_date]
			@account_type		= @config[:account_type]
			@account_subtype	= @config[:account_subtype]
			@branch				= @config[:branch]
			@center 			= @config[:center]

			@non_interest		= @config[:non_interest] || true

			@member_accounts	= MemberAccount.where(
									account_type: @account_type,
									account_subtype: @account_subtype,
									branch: @branch.id
								  )

			if @center.present?
				@member_accounts = @member_accounts.where(center_id: @center.id)
			end

			@data = {
				start_date: @start_date,
				end_date: @end_date,
				branch: @branch,
				members: [],
				total_deposits: 0.00,
				total_withdrawals: 0.00
			}
		end

		def execute!
			@account_transactions = AccountTransaction.where(
										"DATE(transacted_at) >= ? AND DATE(transacted_at) <= ? AND subsidiary_id IN (?)",
										@start_date,
										@end_date,
										@member_accounts.pluck(:id)
									)

			if @non_interest
				@account_transactions = @account_transactions.where.not("data->>'is_interest' = ?", 'true')
			end

			@data[:total_withdrawals] = @account_transactions.where(transaction_type: "withdraw").sum(:amount)
			@data[:total_deposits] = @account_transactions.where(transaction_type: "deposit").sum(:amount)

			@member_accounts = @member_accounts.where(id: @account_transactions.pluck(:subsidiary_id).uniq)

			@members = Member.where(id: @member_accounts.pluck(:member_id))

			@members.each do |member|
				member_account = @member_accounts.where(member_id: member.id).first
				transactions = @account_transactions.where(subsidiary_id: member_account.id).order("transacted_at ASC")

				data_member = {
					member: {
						id: member.id,
						first_name: member.first_name,
						middle_name: member.middle_name,
						last_name: member.last_name
					},
					branch: {
						id: member.branch.id,
						name: member.branch.name
					},
					center: {
						id: member.center.id,
						name: member.center.name
					},
					transactions: transactions
				}

				@data[:members] << data_member
			end

			@data
		end
	end
end