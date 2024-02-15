class MemberAccountValidationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_record, only: [:edit, :update, :destroy, :show]

  def load_record
    @member_account_validation = MemberAccountValidation.find(params[:id])
  end

  def index
    @member_account_validations = MemberAccountValidation
      .includes(:branch)
      .where(branch_id: @branches.pluck(:id))
      .order("date_prepared DESC, status DESC")
      .page(params[:page])
      .per(LIST_PAGE_SIZE)

    if params[:start_date].present? and params[:end_date].present?
      @member_account_validations = @member_account_validations.where("date_prepared >= ? AND date_prepared <= ?", params[:start_date], params[:end_date])
    end

    if (@q = params[:q]).present?
      @member_account_validations = @member_account_validations
        .joins(member_account_validation_records: :member)
        .where("LOWER(members.first_name) LIKE :q OR LOWER(members.last_name) LIKE :q OR LOWER(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if (@status = params[:status]).present?
      @member_account_validations = @member_account_validations.where(status: @status)
    end

    if (@branch_id = params[:branch_id]).present?
      @member_account_validations = @member_account_validations.where(branch_id: @branch_id)
    end

    @subheader_items = [
      {
        text: "Member Account Validations"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new-transaction",
        link: "#",
        class: "fa fa-plus",
        text: "New Member Account Validation"
      }
    ]
  end

  def edit
    @members = Member.active_and_resigned_and_writeoff.where("branch_id = ?", @member_account_validation.branch.id).all.order("last_name ASC")

    @subheader_items = [
      {
        is_link: true,
        path: member_account_validations_path,
        text: "Member Account Validations"
      },
      {
        is_link: true,
        path: member_account_validation_path(@member_account_validation),
        text: "#{@member_account_validation.date_prepared} - #{@member_account_validation.status}"
      },
      {
        text: "Form"
      }
    ]

    @subheader_side_actions = []

    @payload = {
      id: @member_account_validation.id,
      memberAccountValidationStatus: @member_account_validation.status
    }
  end

  def update
    if @member_account_validation.update(member_account_validation_params)
      flash[:success] = "Successfully saved transaction."
      redirect_to member_account_validation_path(@member_account_validation)
    else
      flash[:error] = "Error in saving transaction"

      @subheader_items = [
        {
          is_link: true,
          path: member_account_validations_path,
          text: "Member Account Validations"
        },
        {
          is_link: true,
          path: member_account_validation_path(@member_account_validation),
          text: "#{@member_account_validation.date_prepared} - #{@member_account_validation.status}"
        },
        {
          text: "Form"
        }
      ]

      @subheader_side_actions = []

      @payload = {
        id: @member_account_validation.id,
        memberAccountValidationStatus: @member_account_validation.status
      }

      render :edit
    end
  end


  def show
    @member_account_validation = MemberAccountValidation.find(params[:id])

    if !@member_account_validation.data.nil?
      @accounting_entry_data = @member_account_validation.data.with_indifferent_access[:accounting_entry]
    end

    # @members = Member.where(branch_id: @member_account_validation.branch.id).all
    @role = current_user.roles.last

    @subheader_items = [
      {
        is_link: true,
        path: member_account_validations_path,
        text: "Member Account Validations"
      },
      {
        text: "#{@member_account_validation.date_prepared} - #{@member_account_validation.status}"
      }
    ]

    @subheader_side_actions = []

    @payload = {
      id: @member_account_validation.id
    }
  end

  def destroy
   if @member_account_validation.pending? || @member_account_validation.cancelled?
      @member_account_validation.destroy!
      flash[:success] = "Successfully destroyed member Validation Account."
      redirect_to member_account_validations_path
    else
      flash[:error] = "Cannot destroy record"
      redirect_to member_account_validation_path(@member_account_validation)
    end
  end

  def approve
    member_account_validation = MemberAccountValidation.find(params[:member_account_validation_id])
  end

  def withdrawal_pdf
    @member_account_validation_record = MemberAccountValidationRecord.find(params[:member_account_validation_record_id])
  end

  def pdf
    @member_account_validation = MemberAccountValidation.find(params[:member_account_validation_id])
    if @member_account_validation.approved?
      @accounting_entry = AccountingEntry.where(
                                        reference_number: @member_account_validation.reference_number,
                                        particular: @member_account_validation.data.with_indifferent_access[:accounting_entry][:particular]
                                        ).first
    else
      @accounting_entry = @member_account_validation.data.with_indifferent_access[:accounting_entry]
    end
  end

  def files
    @member_account_validation = MemberAccountValidation.find(params[:member_account_validation_id])
    @member_account_validation_record = MemberAccountValidationRecord.find(params[:member_account_validation_record_id])
  end

  def delete_files
    @member_account_validation = MemberAccountValidation.find(params[:member_account_validation_id])
    @member_account_validation_record = MemberAccountValidationRecord.find(params[:member_account_validation_record_id])
    @member_account_validation_record.files.purge
    
    redirect_to member_account_validation_path(@member_account_validation)


    # @file = ActiveStorage::Attachment.find(params[:id])
    # @file.purge
    # redirect_to member_account_validation_path(@member_account_validation)
  end

  def member_account_validation_params
    params.require(:member_account_validation).permit!
  end
end
