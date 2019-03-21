module Api
	module V1
		class InsuranceAccountsController < ApplicationController

			def fetch_insurance_status
				member_account = MemberAccount.find(params[:member_account_id])

				config = {
					member_account: member_account
				}

				data = ::MemberAccounts::FetchInsuranceStatus.new(
					config: config
					).execute!
				render json: data
			end

		end

	end
end
