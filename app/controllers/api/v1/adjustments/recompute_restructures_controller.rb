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
          
          #for_member_validation = RecomputeRestructure.where(member: member_id)o

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
            user: current_user
          }
          record =  ::Adjustments::RecomputeRestructures::Approve.new(
                                                                config: config
                                                               ).execute!
          
          render json: { message: "ok" }
        end
        
        def destroy
          recompute_restructure_id = params[:id]
          recompute_restructure_details = RecomputeRestructure.find(recompute_restructure_id)
          if !recompute_restructure_details.status == "pending"
            raise "Invalid record #{recompute_restructure_details.id}"
          else
            recompute_restructure_details.destroy!
          end
          render json: { message: "ok" }
        end

      end
    end
  end
end
