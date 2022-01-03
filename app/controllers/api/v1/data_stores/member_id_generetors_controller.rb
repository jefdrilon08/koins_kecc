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
      end
    end
  end
end
