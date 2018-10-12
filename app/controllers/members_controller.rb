class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @member = Member.find(params[:id])

    @active_loans   = Loan.active.where(member_id: params[:id])
    @paid_loans     = Loan.paid.where(member_id: params[:id])
    @pending_loans  = Loan.pending.where(member_id: params[:id])

    @savings_accounts   = MemberAccount.savings.where(member_id: @member.id)
    @insurance_accounts = MemberAccount.insurance.where(member_id: @member.id)

    @loan_balance = @active_loans.sum("principal_balance + interest_balance")
  end
end
