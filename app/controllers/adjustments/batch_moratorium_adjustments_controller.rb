module Adjustments
  class BatchMoratoriumAdjustmentsController < ApplicationController
    before_action :authenticate_user!

    def index
      @adjustment_records = AdjustmentRecord.batch_moratorium

      @adjustment_records = @adjustment_records.page(params[:page]).per(50)
    end

    def show
      @adjustment_record  = AdjustmentRecord.batch_moratorium.find(params[:id])

      @meta = @adjustment_record.meta.with_indifferent_access
      @data = @adjustment_record.data.with_indifferent_access
    end
  end
end
