class ApplicationController < ActionController::Base
  before_action :load_defaults
  layout :layout_by_resource

  def authenticate_admin!
    if user_signed_in? and !current_user.is_mis?
      redirect_to root_path
    elsif !user_signed_in?
      redirect_to root_path
    end
  end

  before_action do
    if params[:rmp]
      Rack::MiniProfiler.authorize_request
    end
  end

  def load_defaults
    @current_date = Date.today

    if user_signed_in?
      @default_branch_name = Settings.try(:defaults).try(:default_branch).try(:name)
      @branches = ReadOnlyBranch.where(
        id: ReadOnlyUserBranch.where(
          active: true, user_id: current_user.id
        ).pluck(
          :branch_id
        )
      ).order(
        Arel.sql(
          "name#{" = '#{@default_branch_name}'" if @default_branch_name} ASC"
        )
      )
    end
  end

  FOR_PDF_PATH = [
    "clip_claims",
    "claims",
    "member_account_validations",
    "insurance_accounts",
    "members",
    "loans"
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
    "certificate_form_pdf",
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
    "calamity_loa_pdf",
    "amortization_pdf"
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
