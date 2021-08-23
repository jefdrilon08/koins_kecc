module Adjustments
  class SubsidiaryAdjustmentsController < ApplicationController
    before_action :authenticate_user!

    def index
      @adjustment_records = AdjustmentRecord.where("meta #>> '{branch, id}' IN (?)", @branches.pluck(:id))
    
      if params[:start_date].present? and params[:end_date].present?
        @adjustment_records = @adjustment_records.where("date_approved >= ? AND date_approved <= ?", params[:start_date], params[:end_date])
      end

      if params[:branch_id].present?
        @branch   = Branch.find(params[:branch_id])
        @adjustment_records = @adjustment_records.where("meta #>> '{branch, id}' = ?", @branch.id)
      end

      if params[:status].present?
        @status = params[:status]
        @adjustment_records = @adjustment_records.where(status: @status)
      end

      @adjustment_records = @adjustment_records.page(params[:page]).per(50)

      @subheader_items = [
        {
          text: "Subsidiary Adjustments"
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
      @adjustment_record  = AdjustmentRecord.subsidiary.find(params[:id])

      @meta = @adjustment_record.meta.with_indifferent_access
      @data = @adjustment_record.data.with_indifferent_access
      @accounting_entry = @data[:accounting_entry]

      #@non_subsidiary_members = @adjustment_record.non_subsidiary_members
      @subsidiary_members = @adjustment_record.selectable_subsidiary_members

      @accounting_codes = AccountingCode.order("code ASC")

      @subheader_items = [
        {
          is_link: true,
          path: adjustments_subsidiary_adjustments_path,
          text: "Subsidiary Adjustments"
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
