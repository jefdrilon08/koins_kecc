class LoansController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @loan                   = Loan.find(params[:id])
    @amortization_schedule  = @loan.amortization_schedule_entries.order(
                                "due_date ASC"
                              )
  end
end
