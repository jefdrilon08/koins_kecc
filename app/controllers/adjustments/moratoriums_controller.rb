module Adjustments
  class MoratoriumsController < ApplicationController
    def index
      @moratoriums  = ReadOnlyMemberMoratorium
                        .includes(:center, :branch)
                        .where(branch_id: @branches.pluck(:id))

      @moratoriums  = @moratoriums.order("status DESC, date_initialized DESC").page(params[:page]).per(LIST_PAGE_SIZE)

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
