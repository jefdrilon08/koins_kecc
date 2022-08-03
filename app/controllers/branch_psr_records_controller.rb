class BranchPsrRecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    @records = BranchPsrRecord.select(
      "*"
    ).where(
      branch_id: @branches.pluck(:id)
    )

    @records = @records.order("closing_date DESC").page(params[:page]).per(LIST_PAGE_SIZE)
  end

  def show
    @record = BranchPsrRecord.find(params[:id])
  end
end
