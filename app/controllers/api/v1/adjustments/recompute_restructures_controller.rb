module Api
  module V1
    module Adjustments
      class RecomputeRestructuresController < ApplicationController
        def create
          branch_id = params[:branch_id]
          center_id = params[:center_id]  
          member_id = params[:member_id]
          config = {
            branch_id: branch_id,
            center_id: center_id,
            member_id: member_id
          }
    
          record =  ::Adjustments::RecomputeRestructures::Create.new(
                                                                config: config
                                                               ).execute!
          
          render json: { id: record.id}
        end

        def approve
          recompute_restructure_id = params[:id]
          recompute_restructure_details = RecomputeRestructure.find(recompute_restructure_id)
          config = {
            recompute_restructure: recompute_restructure_details,
            user_full_name: current_user.full_name
          }
          record =  ::Adjustments::RecomputeRestructures::Approve.new(
                                                                config: config
                                                               ).execute!
          
          render json: { message: "ok" }
        end

      end
    end
  end
end
