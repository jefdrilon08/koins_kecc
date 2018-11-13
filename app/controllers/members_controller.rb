class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
    @members  = Member.select("*").where(branch_id: @branches.pluck(:id))
    @q        = params[:q]
    @status   = params[:status]

    @centers  = @branches.first.centers

    if @q.present?
      @members  = @members.where(
                    "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(identification_number) LIKE :q",
                    q: "#{@q.upcase}%"
                  )
    end

    if @status.present?
      @members  = @members.where(status: @status)
    end

    @members  = @members.order("last_name ASC").page(params[:page]).per(20)
  end

  def form
  end

  def show
    @member = Member.find(params[:id])

    @active_loans   = Loan.active.where(member_id: params[:id])
    @paid_loans     = Loan.paid.where(member_id: params[:id])
    @pending_loans  = Loan.pending.where(member_id: params[:id])

    @savings_accounts   = MemberAccount.savings.where(member_id: @member.id)
    @insurance_accounts = MemberAccount.insurance.where(member_id: @member.id)

    @loan_balance = @active_loans.sum("principal_balance + interest_balance")

    @loan_products  = LoanProduct.select("*").order("name ASC")

    @activity_logs  = ActivityLog.where(
                        "data ->> 'member_id' = ?",
                        @member.id
                      ).order("created_at DESC")
  end
end
