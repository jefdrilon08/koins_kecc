class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_defaults

  def load_defaults
    if params[:start_date].present? and params[:end_date].present?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
    end
    @branches = Branch.all
  end

  def monthly_remittance
  end

  def download_excel_monthly_remittance 
    if params[:start_date].present? and params[:end_date].present?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
    else
      @branch = nil
    end

    if @branch.present?
      filename = "#{@branch}_monthly_remittance.xlsx"
    else
      filename = "monthly_remittance.xlsx"
    end

    excel = Reports::GenerateMonthlyRemittanceExcel.new(start_date: @start_date, end_date: @end_date, branch: @branch).execute!
    excel.serialize "#{Rails.root}/tmp/#{filename}"

    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def print_insured_loans
    @data = Insurance::FetchInsuredLoans.new(start_date: @start_date, end_date: @end_date, loan_status: @loan_status, branch_id: params[:branch_id]).execute!

    if params[:start_date].present? and params[:end_date].present? and params[:loan_status].present? and params[:branch_id].present?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @loan_status = params[:loan_status]
      @branch     = Branch.find(params[:branch_id])

      @data = Insurance::FetchInsuredLoans.new(start_date: @start_date, end_date: @end_date, loan_status: @loan_status, branch_id: @branch.id).execute!
    end

    filename = "#{@branch}_insured_loans.xlsx"
    report_package = Reports::GenerateExcelForInsuredLoans.new(data: @data, start_date: @start_date, end_date: @end_date, loan_status: @loan_status, branch_id: @branch.id).execute!
    report_package.serialize "#{Rails.root}/tmp/#{filename}"

   
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def collections_clip_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]
    branch_name = Branch.where(id: branch).first.name

    excel = Reports::GenerateCollectionsClipReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "#{branch_name}_collections_clip_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def collections_blip_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]
    branch_name = Branch.where(id: branch).first.name
  
    excel = Reports::GenerateCollectionsBlipReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "#{branch_name}_collections_blip_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def member_dependent_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]
    branch_name = Branch.where(id: branch).first.name
  
    excel = Reports::GenerateMemberDependentReportExcel.new(start_date: start_date, end_date: end_date, branch: branch).execute!
    filename  = "#{branch_name}_member_dependent_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
  
  def cic_reports
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @provider_code = params[:provider_code]

    excel = Reports::GenerateCicReportExcel.new(provider_code: @provider_code, start_date: @start_date, end_date: @end_date).execute!
    filename  = "cic_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def monthly_collection_reports
    @start_date = params[:start_date]
    @end_date   = params[:end_date]
    @branch     = Branch.find(params[:branch])


    excel = Reports::GenerateMonthlyCollectionReportExcel.new(branch: @branch, start_date: @start_date, end_date: @end_date).execute!
    
    if @branch.present?
      filename  = "#{@branch}_monthly_collection_reports.xlsx"
    else
      filename  = "monthly_collection_reports.xlsx"
    end


    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def claims_blip
  end

  def claims_blip_report
    branch = params[:branch]
    category_of_cause_of_death_tpd_accident = params[:category_of_cause_of_death_tpd_accident]
    type_of_insurance_policy = params[:type_of_insurance_policy]
    classification_of_insured = params[:classification_of_insured]
    start_date = params[:start_date]
    end_date = params[:end_date]
  
    excel = Reports::GenerateClaimsBlipReportExcel.new(branch: branch, category_of_cause_of_death_tpd_accident: category_of_cause_of_death_tpd_accident, type_of_insurance_policy: type_of_insurance_policy, classification_of_insured: classification_of_insured, start_date: start_date, end_date: end_date).execute!
    filename  = "BLIP_claims_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

<<<<<<< HEAD
  def claims_clip
  end

  def claims_clip_report
    branch = params[:branch]
    cause_of_death = params[:cause_of_death]
    type_of_loan = params[:type_of_loan]
    start_date = params[:start_date]
    end_date = params[:end_date]
  
    excel = Reports::GenerateClaimsClipReportExcel.new(branch: branch, type_of_loan: type_of_loan, start_date: start_date, end_date: end_date).execute!
    filename  = "CLIP_claims_report.xlsx"
=======
  def collections_hiip_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]
    branch_name = Branch.where(id: branch).first.name

    excel = Reports::GenerateCollectionsHiipReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "#{branch_name}_collections_hiip_report.xlsx"
>>>>>>> dev

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
<<<<<<< HEAD
=======

>>>>>>> dev
end
