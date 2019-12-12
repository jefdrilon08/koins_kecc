class KbenteClaimsController < ApplicationController
  # before_action :load_defaults, :authenticate_user!

  def kbente_claim_validation_pdf
    @kbente_claim = KbenteClaim.find(params[:kbente_claim_id])
    @member = @kbente_claim.member
  end

  def kbente_claim_loa_pdf
    @kbente_claim = KbenteClaim.find(params[:kbente_claim_id])
    @member = @kbente_claim.member
  end

  def index
    @kbente_claims = KbenteClaim.all.order("created_at DESC")

    if params[:q].present?
      @q = params[:q]
      @kbente_claims = @kbente_claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @kbente_claims = @kbente_claims.where(branch_id: @branch.id)
    end
  @kbente_claims = @kbente_claims.page(params[:page]).per(20)
  end

  def new
    @kbente_claim = KbenteClaim.new
  end

  def create
    @kbente_claim = KbenteClaim.new(kbente_claim_params)

    if @kbente_claim.save
      flash[:success] = "Successfully saved kbente claim record."
      redirect_to kbente_claim_path(@kbente_claim.id)
    else
      flash.now[:error] = "Error in saving kbente claim record."
      render :new
    end
  end

  def edit 
     @kbente_claim = KbenteClaim.find(params[:id])
  end

  def update
    @kbente_claim = KbenteClaim.find(params[:id])

    if @kbente_claim.update_attributes(kbente_claim_params)
      flash[:success] = "Successfully saved kbente claim record."
      redirect_to kbente_claim_path(@kbente_claim.id)
    else
      flash[:error] = "Error in saving kbente claim record."
      render :edit
    end
  end

  def new_kbente_claim_application
    @member = Member.find(params[:member_id])
    redirect_to new_member_kbente_claim_path(@member)
  end

  def destroy
    @kbente_claim = KbenteClaim.find(params[:id])
    @kbente_claim.destroy!
    flash[:success] = "Successfully removed kbente claim"
    redirect_to kbente_claims_path
  end

  def show
    @kbente_claim = KbenteClaim.find(params[:id])
  end

  def kbente_claim_params 
    params.require(:kbente_claim).permit!
  end
end
