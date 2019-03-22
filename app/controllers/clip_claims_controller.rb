class ClipClaimsController < ApplicationController
  # before_action :load_defaults, :authenticate_user!

  def clip_claim_validation_pdf
    @clip_claim = ClipClaim.find(params[:clip_claim_id])
    @member = @clip_claim.member
  end

  def clip_claim_loa_pdf
    @clip_claim = ClipClaim.find(params[:clip_claim_id])
    @member = @clip_claim.member
  end

  def index
    #@clip_claims = ClipClaim.all.includes(:member).order("members.last_name")
    @clip_claims = ClipClaim.all.order("date_prepared DESC")

    if params[:q].present?
      @q = params[:q]
      @clip_claims = @clip_claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @clip_claims = @clip_claims.where(branch_id: @branch.id)
    end
  
  @clip_claims = @clip_claims.page(params[:page]).per(20)
  end

  def new
    @clip_claim = ClipClaim.new
  end

  def create
    @clip_claim = ClipClaim.new(clip_claim_params)

    if @clip_claim.save
      flash[:success] = "Successfully saved clip claim record."
      redirect_to clip_claim_path(@clip_claim.id)
    else
      flash.now[:error] = "Error in saving clip claim record."
      render :new
    end
  end

  def edit 
     @clip_claim = ClipClaim.find(params[:id])
  end

  def update
    @clip_claim = ClipClaim.find(params[:id])

    if @clip_claim.update_attributes(clip_claim_params)
      flash[:success] = "Successfully saved clip claim record."
      redirect_to clip_claim_path(@clip_claim.id)
    else
      flash[:error] = "Error in saving clip claim record."
      render :edit
    end
  end

  def new_clip_claim_application
    @member = Member.find(params[:member_id])
    redirect_to new_member_clip_claim_path(@member)
  end

  def destroy
    @clip_claim = ClipClaim.find(params[:id])
    @clip_claim.destroy!
    flash[:success] = "Successfully removed clip claim"
    redirect_to clip_claims_path
  end

  def show
    @clip_claim = ClipClaim.find(params[:id])
  end

  def clip_claim_params 
    params.require(:clip_claim).permit!
  end
end
