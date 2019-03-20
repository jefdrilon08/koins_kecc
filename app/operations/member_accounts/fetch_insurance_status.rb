module MemberAccounts
	class FetchInsuranceStatus

		def initialize(config:)
			@config = config
			@member_account = @config[:member_account]
			@member = @member_account.member
			@member_data = @member.data.with_indifferent_access
			@recognition_date = @member_data[:recognition_date].try(:to_date)
			@current_date = Date.today
			@account_transactions = AccountTransaction.where(
									"subsidiary_id = ?",
									@member_account.id).order("transacted_at ASC")

			@latest_transaction = @account_transactions.last
			@current_balance = @member_account.balance

			@default_periodic_payment = 15

			@data = {
				recognition_date: @recognition_date,
				length_of_membership: 0,
				current_date: @current_date,
				num_weeks: 0,
				insured_amount: 0.00

			}

		end

		def execute!


			@data
		end

	end
end
