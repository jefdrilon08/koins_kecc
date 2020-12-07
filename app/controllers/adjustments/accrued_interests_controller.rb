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
          text: "Individual Process"
        }
      ]
    end
    def show
      @adjustment_record  = AccruedInterest.find(params[:id])
      if params[:center_id].present?
        @ctr_name         = Center.find(params[:center_id]).name 
      end
      
      #raise @adjustment_record_id.id
      #@meta = @adjustment_record.meta.with_indifferent_access
      #@data = @adjustment_record.data.with_indifferent_access
      #@accounting_entry = @data[:accounting_entry]

      #@non_subsidiary_members = @adjustment_record.non_subsidiary_members
      #@subsidiary_members = @adjustment_record.selectable_subsidiary_members

      #@accounting_codes = AccountingCode.order("code ASC")

      @subheader_items = [
        {
          is_link: true,
          path: adjustments_accrued_interests_path,
          text: "Accrued Interests"
        }
      ]

  
    end
  end
end
