class HiipClaimsController < ApplicationController


  def hiip_claim_validation_pdf
    @hiip_claim = HiipClaim.find(params[:hiip_claim_id])
    @member = @hiip_claim.member
  end

  def hiip_claim_loa_pdf
    @hiip_claim = HiipClaim.find(params[:clip_claim_id])
    @member = @hiip_claim.member
  end

  def index
    #@clip_claims = ClipClaim.all.includes(:member).order("members.last_name")
    @hiip_claims = HiipClaim.all.order("date_posted DESC")

    if params[:q].present?
      @q = params[:q]
      @hiip_claims = @hiip_claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @hiip_claims = @hiip_claims.where(branch_id: @branch.id)
    end
  
  
  end

  def new
    @hiip_claim = HiipClaim.new
  end

  def create
    @hiip_claim = HiipClaim.new(hiip_claim_params)

    if @hiip_claim.save
      flash[:success] = "Successfully saved hiip claim record."
      redirect_to hiip_claim_path(@hiip_claim.id)
    else
      flash.now[:error] = "Error in saving hiip claim record."
      render :new
    end
  end

  def edit 
     @hiip_claim = HiipClaim.find(params[:id])
  end

  def update
    @hiip_claim = HiipClaim.find(params[:id])

    if @hiip_claim.update_attributes(hiip_claim_params)
      flash[:success] = "Successfully saved hiip claim record."
      redirect_to hiip_claim_path(@hiip_claim.id)
    else
      flash[:error] = "Error in saving hiip claim record."
      render :edit
    end
  end

  def new_hiip_claim_application
    @member = Member.find(params[:member_id])
    redirect_to new_member_hiip_claim_path(@member)
  end

  def destroy
    @hiip_claim = HiipClaim.find(params[:id])
    @hiip_claim.destroy!
    flash[:success] = "Successfully removed hiip claim"
    redirect_to hiip_claims_path
  end

  def show
    @hiip_claim = HiipClaim.find(params[:id])
  end

  def hiip_claim_params 
    params.require(:hiip_claim).permit!
  end
end
