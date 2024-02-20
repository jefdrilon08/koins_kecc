module Api
  module V1
    module DataStores
      class InvoluntaryMembersController < ActionController::Base
        before_action :authenticate_user!

        def queue
          @branch = Branch.find(params[:branch_id])
          @as_of = params[:as_of]
          @record = DataStore.involuntary_members.where("meta->>'branch_id' = ? AND meta->>'as_of' = ?", @branch.id, @as_of).first

          errors = ::DataStores::ValidateInvoluntaryMembersQueue.new(config: {
            record: @record,
            data_store_type: "INVOLUNTARY_MEMBERS"
           }).execute!

            if errors[:full_messages].any?
              render json: errors, status: 400
              else
                @record = DataStore.create!(
                  meta: {
                    data_store_type: "INVOLUNTARY_MEMBERS",
                    as_of: @as_of,
                    branch_id: @branch.id,
                    branch_name: @branch.name
                  },
                  data: {
                    record: []
                  },
                  status: "processing",
                  as_of: @as_of
                  )

                args = {
                  id: @record.id,
                  user_id: current_user.id
                }
               
                ProcessInvoluntaryMembers.perform_later(args)

                render json: { message: "ok", id: @record.id }
          end
        end

        

      
      end
    end
  end
end
