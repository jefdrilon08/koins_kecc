module Adjustments
  class SubsidiaryAdjustmentsController < ApplicationController
    before_action :authenticate_user!

    def index
    end

    def show
      @adjustment_record  = AdjustmentRecord.subsidiary.find(params[:id])

      @meta = @adjustment_record.meta.with_indifferent_access
      @data = @adjustment_record.data.with_indifferent_access
    end
  end
end
