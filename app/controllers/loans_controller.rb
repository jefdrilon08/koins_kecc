class LoansController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @loan                   = Loan.find(params[:id])
    @amortization_schedule  = @loan.amortization_schedule_entries.order(
                                "due_date ASC"
                              )

    @loan_payments  = AccountTransaction.approved_loan_payments.where(
                        subsidiary_id: @loan.id,
                        subsidiary_type: "Loan"
                      )
  end
end
