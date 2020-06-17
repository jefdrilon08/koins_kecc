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

    # if params[:type_of_insurance_policy].present?
    #   @type_of_insurance_policy = params[:type_of_insurance_policy]
    #   @claims = @claims.where(type_of_insurance_policy: @type_of_insurance_policy)
    # end
  
    #  @claims = @claims.page(params[:page]).per(LIST_PAGE_SIZE)

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

    @payload = {
      id: @claim.id
    }
  end

  def edit
    @claim = Claim.find(params[:id])

    @payload = {
      id: @claim.id
    }
  end

  def index
    @claims = Claim.all.includes(:member, :branch).where(branch_id: @branches.pluck(:id)).order("date_prepared DESC")

    if params[:member].present?
      @member = params[:member]
      @claims = @claims.joins(:member).where("lower(members.first_name) LIKE :member OR lower(members.last_name) LIKE :member OR lower(members.middle_name) LIKE :member", member: "%#{@member.downcase}%")
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

    @subheader_items = [
      {
        text: "Microinsurance"
      },
      {
        text: "Claims Register"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new-transaction",
        link: "#",
        class: "fa fa-plus",
        text: "New Claims"
      }
    ]
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
