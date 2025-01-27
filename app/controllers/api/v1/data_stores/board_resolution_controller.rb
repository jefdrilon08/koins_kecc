module Api
    module V1
      module DataStores
        class BoardResolutionController < ApiController
          before_action :authenticate_user!
  
          def create
              config = {
                branch: Branch.find(params[:branch_id]),
                date_from: params[:date_from],
                date_to: params[:date_to],
                current_user: current_user,
                status: params[:status],
                board_resolution_number: params[:board_resolution_number]
              }
              result = ProcessCreateBoardResolutionNumber.perform_later(config)
              render json: { success: true, message: "success"}

          end


          def approve
            record = DataStore.find(params[:id])
            config = {
            data_store: record,
            user: current_user.id
            } 
              result = ProcessApproveBoardResolutionNumber.perform_later(config)
          
              render json: {
                success: true,
                message: result
              }
          end
          

        end
      end
    end
  end
  