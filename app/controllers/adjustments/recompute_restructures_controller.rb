module Adjustments
  class RecomputeRestructuresController < ApplicationController
    def index
      @restucture_details = RecomputeRestructure.where(branch: @branches.pluck(:id))
      @subheader_items = [
        {
          text: "Recompute Restructure"
        }
      ]
      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
    end
    def show
      @subheader_items = [
        {
          is_link: true,
          path: adjustments_recompute_restructures_path, 
          text: "Recompute Restructure"
        }
      ]
     restructure_id =  params[:id]
     @restucture_details = RecomputeRestructure.find( restructure_id)
     
     @loan = Loan.find(@restucture_details.loan)
     
      @subheader_side_actions = []
     
      if @restucture_details.status == "pending"

        @subheader_side_actions << {
      
          class: "fa fa-times",
          data: { method: :delete, confirm: "Are you sure?" },
          text: "Delete"
        }

        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }
      end
    @payload = {
      id:  @restucture_details.id
    }
    end

  end
end
