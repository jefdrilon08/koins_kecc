class ClaimsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_defaults
  # before_action :load_defaults, :authenticate_user!

  def claim_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @member = @claim.member
  end

  def claim_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @member = @claim.member
    @cluster = @member.branch.cluster
  end

  def index
    #@claims = Claim.all.includes(:member).order("members.last_name")
    @claims = Claim.all.order("date_prepared DESC")

    if params[:q].present?
      @q = params[:q]
      @claims = @claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @claims = @claims.where(branch_id: @branch.id)
    end

    if params[:type_of_insurance_policy].present?
      @type_of_insurance_policy = params[:type_of_insurance_policy]
      @claims = @claims.where(type_of_insurance_policy: @type_of_insurance_policy)
    end
  
     @claims = @claims.page(params[:page]).per(LIST_PAGE_SIZE)
  end

  def new
    @claim = Claim.new
  end

  def create
    @claim = Claim.new(claim_params)

    if @claim.save
      redirect_to claim_path(@claim)
    else
      render :new
    end
  end

  def edit 
     @claim = Claim.find(params[:id])
  end

  def update
    @claim = Claim.find(params[:id])
    @claim.member = @member

    if @claim.update_attributes(claim_params)
      redirect_to claim_path(@claim)
    else
      render :edit
    end
  end

  def new_claim_application
    @member = Member.find(params[:member_id])
    redirect_to new_member_claim_path(@member)
  end

  def destroy
    @claim = Claim.find(params[:id])
    @claim.destroy!
    flash[:success] = "Successfully removed claim"
    redirect_to claims_path
  end

  def show
    @claim = Claim.find(params[:id])
    @member = @claim.member
  end

  def claim_params 
    params.require(:claim).permit!
  end
end
