module Adjustments
  class MoratoriumsController < ApplicationController
    def index
      @moratoriums  = ReadOnlyMemberMoratorium
                        .where(branch_id: @branches.pluck(:id))
                        #.includes(:center, :branch)

      # Filter
      if params[:f_branch_id].present?
        @branch = Branch.find(params[:f_branch_id])
        @moratoriums  = @moratoriums.where(branch_id: @branch.id)
      end

      if params[:f_status].present?
        @status       = params[:f_status]
        @moratoriums  = @moratoriums.where(status: @status)
      end

      if params[:f_start_date].present? and params[:f_end_date].present?
        @start_date = params[:f_start_date].to_date
        @end_date   = params[:f_end_date].to_date

        @moratoriums  = @moratoriums.where(
                          "date_initialized >= ? AND date_initialized <= ?",
                          @start_date,
                          @end_date
                        )
      end

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
