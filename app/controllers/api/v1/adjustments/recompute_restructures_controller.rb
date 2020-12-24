module Api
  module V1
    module Adjustments
      class RecomputeRestructuresController < ApplicationController
        def create
          branch_id = params[:branch_id]
          branch = Branch.where(id: params[:branch_id]).first
          center = Center.where(id: params[:center_id]).first
          config = {
            branch_id: params[:branch_id],
            center_id: params[:center_id]
          }
    
          record =  ::Adjustments::RecomputeRestructures::Create.new(
                                                                config: config
                                                               ).execute!
          
          render json: { id: record.id}
        end
      end
    end
  end
end
