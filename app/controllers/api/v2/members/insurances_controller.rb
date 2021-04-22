module Api
  module V2
    module Members
      class InsurancesController < ApiController
        before_action :authenticate_api_member!

        def index
          data  = ::Epassbook::FetchMemberInsurance.new(
                    member: @member 
                  ).execute!

          render json: data
        end

        def show
          account = MemberAccount.find(params[:id])

          data  = ::Epassbook::FetchInsuranceAccount.new(
                    member: @member,
                    account: account
                  ).execute!

          render json: data
        end
      end
    end
  end
end
