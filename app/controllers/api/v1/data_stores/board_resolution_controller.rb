module Api
    module V1
      module DataStores
        class BoardResolutionController < ApiController
          before_action :authenticate_user!
  
          def create
              config = {
                branch: Branch.find(params[:branch_id]),
                month: params[:month],
                year: params[:year],
                current_user: current_user,
                status: params[:status],
                board_resolution_number: params[:board_resolution_number]
              }

              errors = ::BoardResolution::ValidateCreate.new(config: config).execute!

              if errors[:messages].any?
                render json: errors, status: 400
              else
                result = ProcessCreateBoardResolutionNumber.perform_later(config)
                render json: { message: 'Board Resolution Created', status: 200 }
              end

            

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
  