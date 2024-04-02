module Api
  module V1
    module DataStores
      class ShareCapitalSummaryController < ActionController::Base
        before_action :authenticate_user!
        def create
          @branch = params[:branch_id]
          @as_of = params[:as_of]

          config = {
            branch: @branch,
            as_of: @as_of
          }

          errors = ::ShareCapitalSummary::ValidateCreate.new(config: config).execute!

          if errors[:full_messages].any?
            render json: errors, status: 400
          else
            @record = ::ShareCapitalSummary::Create.new(config: config).execute!
            render json: @record
          end

        end

        def fetch
          @record = DataStore.find(params[:id])

          render json: @record
        end

      end  
    end 
  end
end
