module Members
  class KbenteClaimsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def index
      @kbente_claims = KbenteClaim.all
    end

    def new
      @kbente_claim = KbenteClaim.new(member: @member)
    end

    def create
      @kbente_claim = KbenteClaim.new(kbente_claim_params)
      @kbente_claim.member = @member
      @kbente_claim.branch = @member.branch
      @kbente_claim.center = @member.center
      @errors = []
      @errors = Claims::ValidateKbenteClaimDuplication.new(kbente_claim: @kbente_claim).execute!

      if @errors.count <= 0
        if @kbente_claim.save
          flash[:success] = "Successfully created claim"
          redirect_to kbente_claim_path(@kbente_claim)
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
      @kbente_claim = KbenteClaim.find(params[:id])
    end

    def show
      @kbente_claim = KbenteClaim.find(params[:id])
    end

    def update
      @kbente_claim = KbenteClaim.find(params[:id])
      @kbente_claim.member = @member

      if @kbente_claim.update(kbente_claim_params)
        # update the remaining balance
        flash[:success] = "Successfully updated claim"
        redirect_to kbente_claim_path(@kbente_claim)
      else
        flash[:error] = "Error in saving claim"
        render :new
      end
    end

    def kbente_claim_params
      params.require(:kbente_claim).permit!
    end

  end
end
