module Adjustments
  class BatchMoratoriumAdjustmentsController < ApplicationController
    before_action :authenticate_user!

    def index
      @adjustment_records = AdjustmentRecord.batch_moratorium

      @adjustment_records = @adjustment_records.page(params[:page]).per(50)

      @subheader_items = [
        {
          text: "Moratorium Adjustments"
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
      @adjustment_record  = AdjustmentRecord.batch_moratorium.find(params[:id])

      @meta = @adjustment_record.meta.with_indifferent_access
      @data = @adjustment_record.data.with_indifferent_access

      @subheader_items = [
        {
          is_link: true,
          path: adjustments_batch_moratorium_adjustments_path,
          text: "Batch Moratorium Adjustments"
        },
        {
          text: "Adjustment for #{@meta[:branch][:name]}"
        }
      ]

      @subheader_side_actions = []

      if @adjustment_record.pending?
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }

        @subheader_side_actions << {
          id: "btn-delete",
          link: "#",
          class: "fa fa-times",
          text: "Delete"
        }
      end

      @payload = {
        id: @adjustment_record.id
      }
    end
  end
end
