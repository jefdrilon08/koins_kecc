module Members
  class KjspClaimsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def index
      @kjsp_claims = KjspClaim.all
    end

    def new
      @kjsp_claim = KjspClaim.new(member: @member)
    end

    def create
      @kjsp_claim = KjspClaim.new(kjsp_claim_params)
      @kjsp_claim.member = @member
      @kjsp_claim.branch = @member.branch
      @kjsp_claim.center = @member.center
      @errors = []
      @errors = Claims::ValidateKjspClaimDuplication.new(kjsp_claim: @kjsp_claim).execute!

      if @errors.count <= 0
        if @kjsp_claim.save
          flash[:success] = "Successfully created claim"
          redirect_to kjsp_claim_path(@kjsp_claim)
        else
          flash[:error] = "Error in creating claim"
          render :new
        end
      else
        flash[:error] = "Error in creating claim : #{@errors}"
        render :new
      end
    end

    def edit
      @kjsp_claim = KjspClaim.find(params[:id])
    end

    def show
      @kjsp_claim = KjspClaim.find(params[:id])
    end

    def update
      @kjsp_claim = KjspClaim.find(params[:id])
      @kjsp_claim.member = @member

      if @kjsp_claim.update(kjsp_claim_params)
        # update the remaining balance
        flash[:success] = "Successfully updated claim"
        redirect_to kjsp_claim_path(@kjsp_claim)
      else
        flash[:error] = "Error in saving claim"
        render :new
      end
    end

    def kjsp_claim_params
      params.require(:kjsp_claim).permit!
    end

  end
end
