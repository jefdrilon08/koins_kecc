class LoansController < ApplicationController
  before_action :authenticate_user!

  def index
    @loans            = Loan.includes(:center, :branch, :member, :loan_product)
                            .where("loans.branch_id IN (?)", @branches.pluck(:id))
    @q                = params[:q]
    @status           = params[:status]
    @loan_product_id  = params[:loan_product_id]
    @branch_id        = params[:branch_id]

    @centers  = @branches.first.centers

    if @q.present?
      @members  = Member.where(
                    "upper(members.first_name) LIKE :q OR upper(members.last_name) LIKE :q OR upper(members.identification_number) LIKE :q AND members.branch_id IN (:b)",
                    q: "#{@q.upcase}%",
                    b: @branches.pluck(:id)
                  )

      @loans  = @loans.where(member_id: @members.pluck(:id))
    end

    if @branch_id.present?
      @branch = Branch.find(@branch_id)

      @loans  = @loans.where(branch_id: @branch.id)
    end

    if @loan_product_id.present?
      @loans  = @loans.where(loan_product_id: @loan_product_id)
    end

    if @status.present?
      @loans  = @loans.joins(:member).where(status: @status)
    end

    @loans  = @loans.order("members.last_name ASC, loans.status ASC").page(params[:page]).per(LIST_PAGE_SIZE)
  end

  def form
    if params[:id].present?
      loan  = Loan.find(params[:id])

      @member = Member.where(id: params[:member_id]).first
      @branch = @member.branch

      if @member.blank?
        redirect_to members_path
      end

      if loan.is_restructured
        redirect_to member_path(@member)
      end
    else
      redirect_to loans_path(message: "loan id not found")
    end
  end

  def adjustment
    @loan               = Loan.find(params[:loan_id])
    @adjustment_record  = AdjustmentRecord.reamortization.find(params[:adjustment_record_id])

    @data = @adjustment_record.data.with_indifferent_access
    @meta = @adjustment_record.data.with_indifferent_access
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

    @adjustment_records = AdjustmentRecord.reamortization.where(
                            "meta->>'loan_id' = ?",
                            @loan.id
                          ).order("created_at DESC")
  end
end
