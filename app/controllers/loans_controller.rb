class LoansController < ApplicationController
  before_action :authenticate_user!

  def index
    @loans            = ReadOnlyLoan.includes(:center, :branch, :member, :loan_product)
                            .where("loans.branch_id IN (?)", @branches.pluck(:id))

    @q                = params[:q]
    @status           = params[:status] || "active"
    @loan_product_id  = params[:loan_product_id]
    @branch_id        = params[:branch_id]

    @centers  = @branches.first.centers

    if @q.present?
      @members  = ReadOnlyMember.where(
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
      @loans  = @loans.where(status: @status)
    end

    @loans  = @loans.order("members.last_name ASC, loans.status ASC").page(params[:page]).per(LIST_PAGE_SIZE)
  

    @subheader_items = [
      { text: "Loans" }
    ]
  end

  def form
    if params[:id].present?
      loan  = Loan.find(params[:id])
    end

    if loan.present? and loan.is_restructured
      redirect_to member_path(@member)
    end

    @member = Member.where(id: params[:member_id]).first
    @branch = @member.branch

    if @member.blank?
      redirect_to members_path
    end

    # subheader items
    @subheader_items = [
      {
        is_link: true,
        path: loans_path,
        text: "Loans"
      },
      {
        is_link: true,
        path: member_path(@member),
        text: "#{@member.full_name}"
      },
      {
        text: "Loan Application"
      }
    ]

    @subheader_side_actions = []

    @payload = {
      id: params[:id],
      memberId: @member.id,
      banks: @banks
    }
  end

  def adjustment
    @loan               = Loan.find(params[:loan_id])
    @adjustment_record  = AdjustmentRecord.reamortization.find(params[:adjustment_record_id])

    @data = @adjustment_record.data.with_indifferent_access
    @meta = @adjustment_record.data.with_indifferent_access
  end

  def show
    @loan                   = ReadOnlyLoan.find(params[:id])
    @amortization_schedule  = @loan.amortization_schedule_entries.order(
                                "due_date ASC"
                              )

    @loan_payments  = ReadOnlyAccountTransaction.approved_loan_payments.where(
                        subsidiary_id: @loan.id,
                        subsidiary_type: "Loan"
                      )

    @activity_logs  = ReadOnlyActivityLog.where(
                        "data ->> 'loan_id' = ?",
                        @loan.id
                      ).order("created_at DESC")

    @adjustment_records = AdjustmentRecord.reamortization.where(
                            "meta->>'loan_id' = ?",
                            @loan.id
                          ).order("created_at DESC")

    # subheader items
    @subheader_items = [
      {
        is_link: true,
        path: loans_path,
        text: "Loans"
      },
      {
        is_link: true,
        path: member_path(@loan.member_id),
        text: "#{@loan.member.full_name}"
      },
      {
        text: "#{@loan.pn_number} - #{@loan.cycle.present? ? "Cycle #{@loan.cycle}" : "NO LOAN CYCLE PRESENT"}"
      }
    ]

    @subheader_side_actions = []

    if @loan.pending?
      @subheader_side_actions << {
        id: "btn-approve",
        class: "fa fa-check",
        link: "#",
        text: "Approve"
      }

      if !@loan.is_restructured
        @subheader_side_actions << {
          class: "fa fa-pencil-alt",
          link: loan_application_form_path(id: @loan.id, member_id: @loan.member_id),
          text: "Edit"
        }
      end

      @subheader_side_actions << {
        id: "btn-delete",
        class: "fa fa-times",
        text: "Delete",
        link: "#"
      }
    end

    @payload = {
      id: @loan.id,
      memberId: @loan.member_id
    }
  end
end
