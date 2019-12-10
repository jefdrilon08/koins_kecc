class KalingaClaimsController < ApplicationController

  def index
    @kalinga_claims = KalingaClaim.all

    if params[:q].present?
      @q = params[:q]
      @kalinga_claims = @kalinga_claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @kalinga_claims = @kalinga_claims.where(branch_id: @branch.id)
    end
  @kalinga_claims = @kalinga_claims.page(params[:page]).per(20)
  end

  def new
    @kalinga_claim = KalingaClaim.new
  end

  def create
    @kalinga_claim = KalingaClaim.new(kalinga_claim_params)

    if @kalinga_claim.save
      redirect_to kalinga_claim_path(@kalinga_claim.id)
    else
      render :new
    end
  end

  def edit 
     @kalinga_claim = KalingaClaim.find(params[:id])
  end

  def update
    @kalinga_claim = KalingaClaim.find(params[:id])

    if @kalinga_claim.update_attributes(kalinga_claim_params)
      flash[:success] = "Successfully saved kalinga claim record."
      redirect_to kalinga_claim_path(@kalinga_claim.id)
    else
      flash[:error] = "Error in saving kalinga claim record."
      render :edit
    end
  end

  def new_kalinga_claim_application
    @member = Member.find(params[:member_id])
    redirect_to new_member_kalinga_claim_path(@member)
  end

  def destroy
    @kalinga_claim = KalingaClaim.find(params[:id])
    @kalinga_claim.destroy!
    flash[:success] = "Successfully removed kalinga claim"
    redirect_to kalinga_claims_path
  end

  def show
    @kalinga_claim = KalingaClaim.find(params[:id])
  end

  def kalinga_claim_params 
    params.require(:kalinga_claim).permit!
  end

end
