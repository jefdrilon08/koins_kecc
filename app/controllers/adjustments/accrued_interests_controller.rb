module Adjustments
  class AccruedInterestsController < ApplicationController
    def index
      
      @accrued_interests =  AccruedInterest.where(branch: @branches.pluck(:name))

      
      @subheader_items = [
        {
          text: "Accrued Interest"
        }
      ]
      @subheader_side_actions = [
        {
          id: "btn-batch-process",
          link: "#",
          class: "fa fa-sync",
          text: "Batch Process"
        },
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
    end
  end
end
