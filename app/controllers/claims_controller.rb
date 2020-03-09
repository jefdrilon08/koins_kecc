class ClaimsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_defaults

  def blip_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def blip_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def calamity_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def calamity_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def clip_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def clip_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def hiip_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def hiip_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kalinga_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kalinga_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kbente_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kbente_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_contract_highschool_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_contract_college_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def new
    @claim = Claim.find(params[:id])
  end

  def edit
    @claim = Claim.find(params[:id])
  end

  def index
    @claims = Claim.all.order("date_prepared DESC")

    if params[:q].present?
      @q = params[:q]
      @claims = @claims.joins(:member).where("lower(members.first_name) LIKE :q OR lower(members.last_name) LIKE :q OR lower(members.middle_name) LIKE :q", q: "%#{@q.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @claims = @claims.where(branch_id: @branch.id)
    end

    if params[:claim_type].present?
      @claim_type = params[:claim_type]
      @claims = @claims.where(claim_type: @claim_type)
    end

    if params[:status].present?
      @status = params[:status]
      @claims = @claims.where(status: @status)
    end
  
     @claims = @claims.page(params[:page]).per(25)
  end
  
  def destroy
    @claim = Claim.find(params[:id])
    @claim.destroy!
    flash[:success] = "Successfully removed claim"
    redirect_to claims_path
  end

  def show
    @claim            = Claim.find(params[:id])
    @data             = @claim.data.try(:with_indifferent_access) || {}
  end


end
