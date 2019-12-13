class KjspClaimsController < ApplicationController
  # before_action :load_defaults, :authenticate_user!

  def kjsp_claim_validation_pdf
    @kjsp_claim = KjspClaim.find(params[:kjsp_claim_id])
    @member = @kjsp_claim.member
  end

  def kjsp_contract_pdf
    @kjsp_claim = KjspClaim.find(params[:kjsp_claim_id])
    @member = @kjsp_claim.member
  end

  def kjsp_claim_loa_pdf
    @kjsp_claim = KjspClaim.find(params[:kjsp_claim_id])
    @member = @kjsp_claim.member
  end

  def index
    @kjsp_claims = KjspClaim.all.order("date_prepared DESC")

    if params[:q].present?
      @q = params[:q]
      @kjsp_claims = @kjsp_claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @kjsp_claims = @kjsp_claims.where(branch_id: @branch.id)
    end
  @kjsp_claims = @kjsp_claims.page(params[:page]).per(20)
  end

  def new
    @kjsp_claim = KjspClaim.new
  end

  def create
    @kjsp_claim = KjspClaim.new(kjsp_claim_params)

    if @kjsp_claim.save
      flash[:success] = "Successfully saved claim record."
      redirect_to kjsp_claim_path(@kjsp_claim.id)
    else
      flash.now[:error] = "Error in saving claim record."
      render :new
    end
  end

  def edit 
     @kjsp_claim = KjspClaim.find(params[:id])
  end

  def update
    @kjsp_claim = KjspClaim.find(params[:id])

    if @kjsp_claim.update_attributes(kjsp_claim_params)
      flash[:success] = "Successfully saved claim record."
      redirect_to kjsp_claim_path(@kjsp_claim.id)
    else
      flash[:error] = "Error in saving claim record."
      render :edit
    end
  end

  def new_kjsp_claim_application
    @member = Member.find(params[:member_id])
    redirect_to new_member_kjsp_claim_path(@member)
  end

  def destroy
    @kjsp_claim = KjspClaim.find(params[:id])
    @kjsp_claim.destroy!
    flash[:success] = "Successfully removed claim"
    redirect_to kjsp_claims_path
  end

  def show
    @kjsp_claim = KjspClaim.find(params[:id])
  end

  def kjsp_claim_params 
    params.require(:kjsp_claim).permit!
  end
end
