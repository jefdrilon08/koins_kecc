module Api
	module V1
		class InsuranceAccountsController < ApplicationController
      def process_insurance_account_transactions_file
        actual_url  = params[:actual_url]

        ProcessInsuranceAccountTransactionsFile.perform_later({
          actual_url: actual_url
        })

        render json: { message: "ok" }
      end

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
