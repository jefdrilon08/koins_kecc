module Api
  module V1
    module DataStores
      class ShareCapitalInvoluntaryController < ActionController::Base
        before_action :authenticate_user!

        def queue
          @branch = Branch.find(params[:branch_id])
          @as_of = params[:as_of]
          @record = DataStore.share_capital_involuntary.where("meta->>'branch_id' = ? AND meta->>'as_of' = ?", @branch.id, @as_of).first


            if @record.present?
              render json: "duplucate record", status: 400
              else
                @record = DataStore.create!(
                  meta: {
                    data_store_type: "SHARE_CAPITAL_INVOLUNTARY",
                    as_of: @as_of,
                    branch_id: @branch.id,
                    branch_name: @branch.name
                  },
                  data: {
                    records: []
                  },
                  status: "processing",
                  as_of: @as_of
                  )

                args = {
                  id: @record.id,
                  user_id: current_user.id
                }
              
                #ProcessInvoluntaryMembers.perform_later(args)
                ProcessShareCapitalInvoluntary.perform_later(args)

                render json: { message: "ok", id: @record.id }
          end
        end

        

      
      end
    end
  end
end
