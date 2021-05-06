module Accounting
  class YearEndClosingsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.year_end_closings.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )
      @records  = @records.order("created_at DESC").page(params[:page]).per(20)
      
      # @records  = @records.order(
      #               "CAST(meta->>'closing_date' AS date) DESC"
      #             ).page(params[:page]).per(20)

      @subheader_items = [
        {
          text: "Year End Closing Records"
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
      @record = DataStore.year_end_closings.find(params[:id])
      @meta   = @record.meta.with_indifferent_access
      @branch = Branch.find(@meta[:branch_id])
      @year   = @meta[:year]

      @data = @record.data.with_indifferent_access

      @subheader_items = [
        {
          is_link: true,
          path: accounting_year_end_closings_path,
          text: "Year End Closing Records"
        },
        {
          text: "For Branch #{@branch} - #{@year}"
        }
      ]

      @subheader_side_actions = []

      if @record.status == "done"
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }

        @subheader_side_actions << {
          link: accounting_year_end_closing_path(@record),
          class: "fa fa-times",
          text: "Delete"
        }
      end

      @payload = {
        id: @record.id
      }
    end

    def destroy
      @record = DataStore.year_end_closings.find(params[:id])
      @record.destroy!

      redirect_to accounting_year_end_closings_path
    end
  end
end
