module Api
  module V2
    module Members
      class SavingsController < ApiController
        before_action :authenticate_api_member!

        def index
          data  = ::Epassbook::FetchMemberSavings.new(
                    member: @member 
                  ).execute!

          render json: data
        end

        def show
          account = MemberAccount.find(params[:id])

          data  = ::Epassbook::FetchSavingsAccount.new(
                    member: @member,
                    account: account
                  ).execute!

          render json: data
        end
      end
    end
  end
end
