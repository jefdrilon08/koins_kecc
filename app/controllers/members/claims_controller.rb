module Members
  class ClaimsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def index
      @claims = Claim.all
    end

    def new
      @claim = Claim.new(member: @member)
    end

    def create
      @claim = Claim.new(claim_params)
      @claim.member = @member
      @claim.branch = @member.branch
      @claim.center = @member.center
      @errors = []
      @errors = Claims::ValidateClaimDuplication.new(claim: @claim).execute!

      if @errors.count <= 0
        if @claim.save
          flash[:success] = "Successfully created claim"
          redirect_to claim_path(@claim)
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
      @claim = Claim.find(params[:id])
    end

    def show
     @claim = Claim.find(params[:id])
    end

    def update
      @claim = Claim.find(params[:id])
      
      if @claim.update(claim_params)
       # update the remaining balance
        flash[:success] = "Successfully updated claim"
        redirect_to claim_path(@claim)
      else
        flash[:error] = "Error in saving claim"
        render :new
      end
    end

    def claim_params
      params.require(:claim).permit!
    end

  end
end
