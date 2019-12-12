class CalamityClaimsController < ApplicationController
  # before_action :load_defaults, :authenticate_user!

  def calamity_claim_validation_pdf
    @calamity_claim = CalamityClaim.find(params[:calamity_claim_id])
    @member = @calamity_claim.member
  end

  def calamity_claim_loa_pdf
    @calamity_claim = CalamityClaim.find(params[:calamity_claim_id])
    @member = @calamity_claim.member
  end

  def index
    @calamity_claims = CalamityClaim.all.order("created_at DESC")

    if params[:q].present?
      @q = params[:q]
      @calamity_claims = @calamity_claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @calamity_claims = @calamity_claims.where(branch_id: @branch.id)
    end
  @calamity_claims = @calamity_claims.page(params[:page]).per(20)
  end

  def new
    @calamity_claim = CalamityClaim.new
  end

  def create
    @calamity_claim = CalamityClaim.new(calamity_claim_params)

    if @calamity_claim.save
      flash[:success] = "Successfully saved claim record."
      redirect_to calamity_claim_path(@calamity_claim.id)
    else
      flash.now[:error] = "Error in saving claim record."
      render :new
    end
  end

  def edit 
     @calamity_claim = CalamityClaim.find(params[:id])
  end

  def update
    @calamity_claim = CalamityClaim.find(params[:id])

    if @calamity_claim.update_attributes(calamity_claim_params)
      flash[:success] = "Successfully saved claim record."
      redirect_to calamity_claim_path(@calamity_claim.id)
    else
      flash[:error] = "Error in saving claim record."
      render :edit
    end
  end

  def new_calamity_claim_application
    @member = Member.find(params[:member_id])
    redirect_to new_member_calamity_claim_path(@member)
  end

  def destroy
    @calamity_claim = CalamityClaim.find(params[:id])
    @calamity_claim.destroy!
    flash[:success] = "Successfully removed claim"
    redirect_to calamity_claims_path
  end

  def show
    @calamity_claim = CalamityClaim.find(params[:id])
  end

  def calamity_claim_params 
    params.require(:calamity_claim).permit!
  end
end
