module Adjustments
  class MoratoriumsController < ApplicationController
    def index
      @moratoriums  = ReadOnlyMemberMoratorium
                        .where(branch_id: @branches.pluck(:id))
                        #.includes(:center, :branch)

      @moratoriums  = @moratoriums.order("status DESC, date_initialized DESC").page(params[:page]).per(LIST_PAGE_SIZE)

      center_ids  = ReadOnlyMemberMoratorium.pending.pluck(:center_id).uniq

      @centers  = Center.where(id: center_ids, branch_id: @branches.pluck(:id))

      @subheader_items = [
        {
          text: "Moratoriums"
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
