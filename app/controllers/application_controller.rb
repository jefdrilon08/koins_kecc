class ApplicationController < ActionController::Base
  before_action :load_defaults
  layout :layout_by_resource

  before_action do
    if params[:rmp]
      Rack::MiniProfiler.authorize_request
    end
  end

  def load_defaults
    @current_date = Date.today

    if user_signed_in?
      @default_branch_name = Settings.try(:defaults).try(:default_branch).try(:name)
      @branches = ReadOnlyBranch
        .joins(user_branches: :user)
        .where(user_branches: { active: true, user_id: @current_user.id })
        .order("name#{" = '#{@default_branch_name}'" if @default_branch_name} ASC")
    end
  end

  FOR_PDF_PATH = [
    "clip_claims",
    "claims",
    "member_account_validations",
    "insurance_accounts",
    "members"
  ]

  FOR_PDF = [
    "blip_validation_pdf",
    "blip_loa_pdf",
    "clip_validation_pdf",
    "clip_loa_pdf",
    "withdrawal_pdf",
    "pdf",
    "claims_copy_pdf",
    "insurance_account_pdf",
    "blip_form_pdf",
    "hiip_validation_pdf",
    "hiip_loa_pdf",
    "kalinga_validation_pdf",
    "kalinga_loa_pdf",
    "kbente_validation_pdf",
    "kbente_loa_pdf",
    "scholarship_validation_pdf",
    "scholarship_loa_pdf",
    "scholarship_contract_highschool_pdf",
    "scholarship_contract_college_pdf",
    "calamity_validation_pdf",
    "calamity_loa_pdf"
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
