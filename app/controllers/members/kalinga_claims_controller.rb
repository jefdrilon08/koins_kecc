module Members
  class KalingaClaimsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def index
      @kalinga_claims = KalingaClaim.all
    end

    def new
      @kalinga_claim = KalingaClaim.new(member: @member)
    end

    def create
      @kalinga_claim = KalingaClaim.new(kalinga_claim_params)
      @kalinga_claim.member = @member
      @kalinga_claim.branch = @member.branch
      @kalinga_claim.center = @member.center
      @errors = []
      @errors = Claims::ValidateKalingaClaimDuplication.new(kalinga_claim: @kalinga_claim).execute!

      if @errors.count <= 0
        if @kalinga_claim.save
          flash[:success] = "Successfully created claim"
          redirect_to kalinga_claim_path(@kalinga_claim)
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
      @kalinga_claim = KalingaClaim.find(params[:id])
    end

    def show
      @kalinga_claim = KalingaClaim.find(params[:id])
    end

    def update
      @kalinga_claim = KalingaClaim.find(params[:id])
      @kalinga_claim.member = @member

      if @kalinga_claim.update(kalinga_claim_params)
        # update the remaining balance
        flash[:success] = "Successfully updated claim"
        redirect_to kalinga_claim_path(@kalinga_claim)
      else
        flash[:error] = "Error in saving claim"
        render :new
      end
    end

    def kalinga_claim_params
      params.require(:kalinga_claim).permit!
    end

  end
end
