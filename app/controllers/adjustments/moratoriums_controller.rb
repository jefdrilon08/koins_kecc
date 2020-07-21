module Adjustments
  class MoratoriumsController < ApplicationController
    def index
      @subheader_items = [
        {
          text: "Moratoriums"
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
  end
end
