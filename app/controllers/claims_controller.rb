class ClaimsController < ApplicationController

	def index
		@claims = Claim.all.order("date_prepared DESC")
		if params[:q].present?
	      @q = params[:q]
	      @claims = @claims.where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
	    end

	    if params[:branch_id].present?
	      @branch = Branch.find(params[:branch_id])
	      @claims = @claims.where(branch_id: @branch.id)
	    end

	    if params[:type_of_insurance_policy].present?
	      @type_of_insurance_policy = params[:type_of_insurance_policy]
	      @claims = @claims.where(type_of_insurance_policy: @type_of_insurance_policy)
	    end
	end
	
	def new
		@claim = Claim.new
	end

	def create
		
	end

	def new_claim_application
	    @member = Member.find(params[:member_id])
	    redirect_to new_member_claim_path(@member)
  	end

end
