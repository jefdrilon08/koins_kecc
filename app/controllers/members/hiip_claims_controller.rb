module Members
  class HiipClaimsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def index
      @hiip_claims = HiipClaim.all.order("policy_number ASC")
    end

    def new
      @hiip_claim = HiipClaim.new(member: @member)
    end

    def create
      @hiip_claim = HiipClaim.new(hiip_claim_params)
      @hiip_claim.member = @member
      @hiip_claim.branch = @member.branch
      @hiip_claim.center = @member.center
      @hiip_balance = @hiip_claim.balance
      @hiip_amount  = @hiip_claim.amount
      @hiip_claim.balance = 6000 - @hiip_amount
 
      @errors = []
      @errors = Claims::ValidateHiipClaimDuplication.new(hiip_claim: @hiip_claim).execute!

      if @errors.count <= 0
        if @hiip_claim.save
          flash[:success] = "Successfully created clip claim"
          redirect_to hiip_claim_path(@hiip_claim)
        else
          flash[:error] = "Error in creating claim"
          render :new
        end
      else
        flash[:error] = "Error in creating hiip claim : #{@errors}"
        render :new
      end
    end

    def edit
      @hiip_claim = HiipClaim.find(params[:id])
    end

    def show
      @hiip_claim = HiipClaim.find(params[:id])

    end

    def update
      @hiip_claim = HiipClaim.find(params[:id])
      @hiip_claim.member = @member

      if @hiip_claim.update(hiip_claim_params)
        # update the remaining balance
        flash[:success] = "Successfully updated claim"
        redirect_to hiip_claim_path(@hiip_claim)
      else
        flash[:error] = "Error in saving hiip claim"
        render :new
      end
    end

    def hiip_claim_params
      params.require(:hiip_claim).permit!
    end

  end
end
