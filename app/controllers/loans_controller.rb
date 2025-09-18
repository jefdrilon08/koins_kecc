class LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :load_loan!, only: [:show, :adjustment, :reverse_form, :amortization_pdf]

  def load_loan!
    @loan = ReadOnlyLoan.find_by_id(params[:id])

    if @loan.blank?
      redirect_to loans_path
    end
  end

  def index
    @loans = Loan.includes(:member).where(
      "loans.branch_id IN (?)", 
      @branches.pluck(:id)
    )

    @q                      = params[:q]
    @status                 = params[:status] || "active"
    @loan_product_id        = params[:loan_product_id]
    @branch_id              = params[:branch_id]
    @center_id              = params[:center_id]
    
    @is_online_application  = params[:is_online_application]

    @centers = @branches.try(:first).try(:centers) || []

    if @q.present?
      @loans = @loans.where(
        "upper(data->'member'->>'first_name') LIKE :q OR upper(data->'member'->>'last_name') LIKE :q AND loans.branch_id IN (:b)",
        q: "#{@q.upcase}%",
        b: @branches.pluck(:id)
      )
    end

    if @center_id.present?
      @center = Center.find(@center_id)

      @loans  = @loans.where(center_id: @center.id)
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

    if @is_online_application.present?
      @loans = @loans.where(is_online_application: true)
    end

    #@loans  = @loans.order("loans.status ASC, loans.maturity_date ASC").page(params[:page]).per(LIST_PAGE_SIZE)
  
    @loans  = @loans.order(Arel.sql("data->>'member_full_name' ASC"),"loans.status ASC, loans.maturity_date ASC" ).page(params[:page]).per(LIST_PAGE_SIZE)
    
    def for_full_payment
      data = self.data
      data = JSON.parse(data) if data.is_a?(String)
      return {} unless data.is_a?(Hash)
      data["for_full_payment"] || {}
    end
    


    @subheader_items = [
      { text: "Loans" }
    ]
  end

  def form
    if ::Users::FetchValidRoles.new(module_name: :form_edit_loan).execute!.empty?
      redirect_to member_path(@member)
    else
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
      @subheader_side_actions = []
      @subheader_side_actions = [
        {
          text: "Loan Application"
        },
        {
          is_link: true,
          path: member_path(@member),
          text: "#{@member.full_name}"
        }
      ]


      membership_arrangement = @member.membership_arrangement

      if membership_arrangement.present?
        data = membership_arrangement.data.with_indifferent_access

        # Setup use of co maker
        use_co_maker_one    = (data.key?(:use_co_maker_one) and data[:use_co_maker_one] == "true")
        use_co_maker_two    = (data.key?(:use_co_maker_two) and data[:use_co_maker_two] == "true")
        use_co_maker_three  = (data.key?(:use_co_maker_three) and data[:use_co_maker_three] == "true")
      end

      @payload = {
        id: params[:id],
        memberId: @member.id,
        banks: @banks,
        settings: {
          use_co_maker_one: use_co_maker_one,
          use_co_maker_two: use_co_maker_two,
          use_co_maker_three: use_co_maker_three
        }
      }
    end
  end

  def reverse_form
  
    @loan = Loan.find( params[:id])
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

    if @loan.data.with_indifferent_access[:reverse_loan_details].last[:status] == "pending"        
      if helpers.sbk_mis_user
        @subheader_side_actions << {
          id: "btn-approve-reverse-loan",
          class: "fa fa-undo",
          link: "#",
          text: "Approve"
      

        }
      end
      @subheader_side_actions << {
        id: "btn-delete-reverse-loan",
        class: "fa fa-undo",
        link: "#",
        text: "Delete"
      

      }
    end
    
    @record = ::Loans::BuildAccountingEntryForReverse.new(loan: @loan, current_user: current_user).execute!

  
  end


  def adjustment
    @loan               = Loan.find(params[:loan_id])
    @adjustment_record  = AdjustmentRecord.reamortization.find(params[:adjustment_record_id])

    @data = @adjustment_record.data.with_indifferent_access
    @meta = @adjustment_record.data.with_indifferent_access
  end

  def show
    @loan = ReadOnlyLoan.find_by_id(params[:id])
    @accounting_codes = AccountingCode.all
    @amortization_schedule = @loan.amortization_schedule_entries.order(
      "due_date ASC"
    )

    @loan_payments = ReadOnlyAccountTransaction.approved_loan_payments.where(
      subsidiary_id: @loan.id,
      subsidiary_type: "Loan"
    )

    @activity_logs = ReadOnlyActivityLog.where(
      "data ->> 'loan_id' = ?",
      @loan.id
    ).order("created_at DESC")

    @adjustment_records = AdjustmentRecord.reamortization.where(
      "meta->>'loan_id' = ?",
      @loan.id
    ).order("created_at DESC")


    if @loan.has_co_maker_one?
      @co_maker = ReadOnlyMember.find(@loan.data["co_maker_one"]["id"])
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
        path: member_path(@loan.member_id),
        text: "#{@loan.member.full_name}"
      },
      {
        text: "#{@loan.pn_number} - #{@loan.cycle.present? ? "Cycle #{@loan.cycle}" : "NO LOAN CYCLE PRESENT"}"
      }
    ]
    
    @subheader_items << {
      is_link: true,
      path: amortization_pdf_path,
      class: "fa fa-print",
      target: "_blank",
      text: "Print Amortization PDF"
    }

    @subheader_side_actions = []

    if @loan.active? && @loan.interest_paid == 0.0
      if helpers.bk_mis_user
        @subheader_side_actions << {
          id: "btn-reverse-loan",
          class: "fa fa-undo",
          link: "#",
          text: "Reverse Loan"
      

        }
      end
    end
    if @loan.active? && helpers.is_mis_fm?
      @subheader_side_actions << {
        id: "btn-fraud",
        class: "fa fa-upload",
        link: "#",
        text: "Fraud Tagging"
      }
    end

    if @loan.pending?
      @subheader_side_actions << {
        id: "btn-upload-application-form",
        class: "fa fa-upload",
        link: "#",
        text: "Upload Application Form"
      }
    end

    if @loan.for_verification?
      @subheader_side_actions << {
        id: "btn-verify",
        class: "fa fa-check",
        link: "#",
        text: "Verify"
      }
    end

    if ["for-verification", "verified"].include?(@loan.status)
      @subheader_side_actions << {
        id: "btn-reject",
        class: "fa fa-times",
        link: "#",
        text: "Reject"
      }
    end

    if @loan.verified?
      @subheader_side_actions << {
        id: "btn-process",
        class: "fa fa-check",
        link: "#",
        text: "Process"
      }
    end

    if @loan.in_process?
      @subheader_side_actions << {
        id: "btn-for-release",
        class: "fa fa-check",
        link: "#",
        text: "For Release"
      }
    end

    if ["for-verification", "verified", "in-process", "pending"].include?(@loan.status)
      @subheader_side_actions << {
        id: "btn-download-form",
        class: "fa fa-download",
        link: "#",
        text: "Download Form"
      }

      if !@loan.is_restructured
        if ::Users::FetchValidRoles.new(module_name: :form_edit_loan).execute!.any?
          @subheader_side_actions << {
            class: "fa fa-pencil-alt",
            link: loan_application_form_path(id: @loan.id, member_id: @loan.member_id),
            text: "Edit"
          }
        end
      end
    end

    if @loan.pending?
      if helpers.sbk_bk_mis_user
        @subheader_side_actions << {
          id: "btn-approve",
          class: "fa fa-check",
          link: "#",
          text: "Approve"
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
      memberId: @loan.member_id,
      data: ::Loans::BuildFormData.new(loan: @loan).execute!
    }

    # To show the mobile number of member
    @MemberMobileNumber = Member.find(@loan.member_id).mobile_number

  end

  def amortization_pdf
    @amortization_schedule = @loan.amortization_schedule_entries.order(
      "due_date ASC"
    )
  end
end
