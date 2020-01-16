class MemberAccountValidationsController < ApplicationController
  before_action :authenticate_user!
  #before_action :load_defaults, :authenticate_user!
  before_action :load_record, only: [:edit, :update, :destroy, :show]
  #before_action :load_types

  def load_record
    @member_account_validation = MemberAccountValidation.find(params[:id])
  end

  # def load_types
  #   @branches         = Branch.all
  #   @centers          = Center.all
  # end

  def index
    # @member_account_validations = MemberAccountValidation.all.order("date_prepared DESC")
    @member_account_validations = MemberAccountValidation.select("*").where(branch_id: @branches.pluck(:id))
    
    if params[:start_date].present? and params[:end_date].present?
      @member_account_validations = @member_account_validations.where("date_prepared >= ? AND date_prepared <= ?", params[:start_date], params[:end_date])
    end
    
    if params[:q].present?
      @q = params[:q]
      @member_account_validations = MemberAccountValidation.all.joins(member_account_validation_records: :member).where(" lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end
    
    if params[:status].present?
      @status = params[:status]
      @member_account_validations = @member_account_validations.where(status: @status)
    end

    if params[:branch_id].present?
      @branch_id = params[:branch_id]
      @member_account_validations = @member_account_validations.where(branch_id: @branch_id)
    end

    @member_account_validations = @member_account_validations.page(params[:page]).per(20)
  end

  def edit
    @members = Member.active_and_resigned.where("branch_id = ?", @member_account_validation.branch.id).all.order("last_name ASC")
  end

  def update
    if @member_account_validation.update(member_account_validation_params)
      flash[:success] = "Successfully saved transaction."
      redirect_to member_account_validation_path(@member_account_validation)
    else
      flash[:error] = "Error in saving transaction"
      render :edit
    end
  end


  def show 
    @member_account_validation = MemberAccountValidation.find(params[:id])
    

    if !@member_account_validation.data.nil?
      @accounting_entry_data = @member_account_validation.data.with_indifferent_access[:accounting_entry]
    end

    # if @member_account_validation.data.nil?
    #   @accounting_entry = AccountingEntry.where(date_prepared: @member_account_validation.date_approved, reference_number: @member_account_validation.reference_number).first
    #   @journal_entries = @accounting_entry.journal_entries.last
    #   @accounting_code = AccountingCode.where(id: @journal_entries.accounting_code_id).last
    #     @member_account_validation.update!(data: 
    #       {"accounting_entry":
    #         {
    #           book: @accounting_entry.book, 
    #           status: "approved",
    #           company_name: Settings.company_name,
    #           company_address: Settings.company_address,
    #           branch: @accounting_entry.branch.name,
    #           prepared_by: @accounting_entry.prepared_by,
    #           particular: @accounting_entry.particular,
    #           approved_by: @accounting_entry.approved_by,
    #           date_prepared: @accounting_entry.date_prepared,
    #           journal_entries: [
    #             post_type: @journal_entries.post_type,
    #             code_id: @journal_entries.accounting_code_id,
    #             code_name: @accounting_code.name,
    #             amount: @journal_entries.amount
    #           ]
    #         }
    #       })
    # end

    @members = Member.where(branch_id: @member_account_validation.branch.id).all
    @role = current_user.roles.last
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
                                        book: @member_account_validation.data.with_indifferent_access[:accounting_entry][:book],
                                        branch_id: @member_account_validation.data.with_indifferent_access[:accounting_entry][:branch_id]
                                        ).first
    else 
      @accounting_entry = @member_account_validation.data.with_indifferent_access[:accounting_entry]
    end
  end

  def member_account_validation_params
    params.require(:member_account_validation).permit!
  end
end
