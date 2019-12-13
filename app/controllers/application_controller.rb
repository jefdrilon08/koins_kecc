class ApplicationController < ActionController::Base
  before_action :load_defaults
  layout :layout_by_resource

  def load_defaults
    @current_date = Date.today

    if user_signed_in?
      # TODO: Only fetch user assigned branches
      @default_branch_name = Settings.try(:defaults).try(:default_branch).try(:name)
      
      if @default_branch_name.present?
        @branches = Branch.where(id: UserBranch.active.where(user_id: current_user.id).pluck(:branch_id)).order("name='#{@default_branch_name}', name DESC").reverse
        
      else
        @branches = Branch.where(id: UserBranch.active.where(user_id: current_user.id).pluck(:branch_id)).order("name ASC")
      end
    end
  end
  
  FOR_PDF_PATH = [
    "clip_claims",
    "claims",
    "member_account_validations",
    "insurance_accounts",
    "members",
    "hiip_claims",
    "kalinga_claims",
    "kbente_claims",
    "kjsp_claims",
    "calamity_claims"
  ]

  FOR_PDF = [
    "claim_validation_pdf",
    "claim_loa_pdf",
    "clip_claim_validation_pdf",
    "clip_claim_loa_pdf",
    "withdrawal_pdf",
    "pdf",
    "claims_copy_pdf",
    "insurance_account_pdf",
    "blip_form_pdf",
    "hiip_claim_validation_pdf",
    "hiip_claim_loa_pdf",
    "kalinga_claim_validation_pdf",
    "kalinga_claim_loa_pdf",
    "kbente_claim_validation_pdf",
    "kbente_claim_loa_pdf",
    "kjsp_claim_validation_pdf",
    "kjsp_claim_loa_pdf",
    "kjsp_contract_pdf",
    "calamity_claim_validation_pdf",
    "calamity_claim_loa_pdf"
  ]

  def layout_by_resource
    if devise_controller?
      "landing"
    elsif FOR_PDF_PATH.include?(params[:controller]) && FOR_PDF.include?(params[:action])
      "print"
    else
      "application"
    end
  end
end
