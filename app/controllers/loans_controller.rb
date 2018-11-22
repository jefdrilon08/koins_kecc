class LoansController < ApplicationController
  before_action :authenticate_user!

  def index
    @loans            = Loan.where("loans.branch_id IN (?)", @branches.pluck(:id))
    @q                = params[:q]
    @status           = params[:status]
    @loan_product_id  = params[:loan_product_id]

    @centers  = @branches.first.centers

    if @q.present?
      @members  = Member.where(
                    "upper(members.first_name) LIKE :q OR upper(members.last_name) LIKE :q OR upper(members.identification_number) LIKE :q AND members.branch_id IN (:b)",
                    q: "#{@q.upcase}%",
                    b: @branches.pluck(:id)
                  )

      @loans  = @loans.where(member_id: @members.pluck(:id))
    end

    if @loan_product_id.present?
      @loans  = @loans.where(loan_product_id: @loan_product_id)
    end

    if @status.present?
      @loans  = @loans.where(status: @status)
    end

    @loans  = @loans.order("status ASC").page(params[:page]).per(20)
  end

  def form
    @member = Member.where(id: params[:member_id]).first
    @branch = @member.branch

    if @member.blank?
      redirect_to members_path
    end
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

    @activity_logs  = ActivityLog.where(
                        "data ->> 'loan_id' = ?",
                        @loan.id
                      ).order("created_at DESC")
  end
end
