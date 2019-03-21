module Members
  class ClipClaimsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def index
      @clip_claims = ClipClaim.all
    end

    def new
      @clip_claim = ClipClaim.new(member: @member)
    end

    def create
      @clip_claim = ClipClaim.new(clip_claim_params)
      @clip_claim.member = @member
      @clip_claim.branch = @member.branch
      @clip_claim.center = @member.center
      @errors = []
      @errors = Claims::ValidateClipClaimDuplication.new(clip_claim: @clip_claim).execute!

      if @errors.count <= 0
        if @clip_claim.save
          flash[:success] = "Successfully created clip claim"
          redirect_to clip_claim_path(@clip_claim)
        else
          flash[:error] = "Error in creating claim"
          render :new
        end
      else
        flash[:error] = "Error in creating clip claim : #{@errors}"
        render :new
      end
    end

    def edit
      @clip_claim = ClipClaim.find(params[:id])
    end

    def show
      @clip_claim = ClipClaim.find(params[:id])
    end

    def update
      @clip_claim = ClipClaim.find(params[:id])
      @clip_claim.member = @member

      if @clip_claim.update(clip_claim_params)
        # update the remaining balance
        flash[:success] = "Successfully updated claim"
        redirect_to clip_claim_path(@clip_claim)
      else
        UserActivity.create!(user_id: current_user.id, role: current_user.role, content: "Failed to update clip claim for #{@member.to_s}.", email: current_user.email, username: current_user.username, record_reference_id: @clip_claim.id)
        flash[:error] = "Error in saving clip claim"
        render :new
      end
    end

    def clip_claim_params
      params.require(:clip_claim).permit!
    end

  end
end
