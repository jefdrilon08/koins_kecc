module Members
  class CalamityClaimsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def index
      @calamity_claims = CalamityClaim.all
    end

    def new
      @calamity_claim = CalamityClaim.new(member: @member)
    end

    def create
      @calamity_claim = CalamityClaim.new(calamity_claim_params)
      @calamity_claim.member = @member
      @calamity_claim.branch = @member.branch
      @calamity_claim.center = @member.center
      @errors = []
      @errors = Claims::ValidateCalamityClaimDuplication.new(calamity_claim: @calamity_claim).execute!

      if @errors.count <= 0
        if @calamity_claim.save
          flash[:success] = "Successfully created claim"
          redirect_to calamity_claim_path(@calamity_claim)
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
      @calamity_claim = CalamityClaim.find(params[:id])
    end

    def show
      @calamity_claim = CalamityClaim.find(params[:id])
    end

    def update
      @calamity_claim = CalamityClaim.find(params[:id])
      @calamity_claim.member = @member

      if @calamity_claim.update(calamity_claim_params)
        # update the remaining balance
        flash[:success] = "Successfully updated claim"
        redirect_to calamity_claim_path(@calamity_claim)
      else
        flash[:error] = "Error in saving claim"
        render :new
      end
    end

    def calamity_claim_params
      params.require(:calamity_claim).permit!
    end

  end
end
