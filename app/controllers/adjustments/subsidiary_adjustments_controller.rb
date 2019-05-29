module Adjustments
  class SubsidiaryAdjustmentsController < ApplicationController
    before_action :authenticate_user!

    def index
      @adjustment_records = AdjustmentRecord.subsidiary

      @adjustment_records = @adjustment_records.page(params[:page]).per(50)
    end

    def show
      @adjustment_record  = AdjustmentRecord.subsidiary.find(params[:id])

      @meta = @adjustment_record.meta.with_indifferent_access
      @data = @adjustment_record.data.with_indifferent_access
      @accounting_entry = @data[:accounting_entry]

      @non_subsidiary_members = @adjustment_record.non_subsidiary_members

      @accounting_codes = AccountingCode.order("code ASC")
    end
  end
end
