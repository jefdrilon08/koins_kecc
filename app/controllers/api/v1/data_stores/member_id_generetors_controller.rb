module Api
  module V1
    module DataStores
      class MemberIdGeneretorsController < ApplicationController
        def create
          branch_id = params[:branch_id]
          user = current_user
          config = {
            branch_id: branch_id,
            user: user
          }  
          @record = ::DataStores::SaveMemberIdGenerators.new(config: config).execute!
          render json: { message: "ok", id: @record.id }
        end
        
        def fetch_members
          
          @member = Member.where(center_id: params[:id], status: "active").map{ |m|
                                                                {
                                                                  id: m.id,
                                                                  name: m.full_name
                                                                }
                                                              

                                                              }
         render json: { members: @member }
        end

      end
    end
  end
end
