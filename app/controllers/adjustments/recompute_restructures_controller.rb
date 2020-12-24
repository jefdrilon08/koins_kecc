module Adjustments
  class RecomputeRestructuresController < ApplicationController
    def index
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
    end

  end
end
