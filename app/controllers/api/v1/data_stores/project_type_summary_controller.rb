module Api
  module V1
    module DataStores
      class ProjectTypeSummaryController < ApiController
    
        before_action :authenticate_user!
        #skip_before_action :verify_authenticity_token
        
        def create
          branch_id = params[:branch_id]
          user = current_user


          config = {
            branch_id: branch_id,
            user: user
          }

          @record = ::DataStores::SaveProjectTypeSummary.new(config: config).execute!
          
          render json: { message: "ok", id: @record.id } 
        end

      end
    end
  end
end
