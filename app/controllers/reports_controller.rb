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

  def address_update
    @siubheader_items = [
      { text: "Other Reports" },
      { text: "Address For Update" }
    ]
      @branches = Branch.all
      branch_id              = params[:branch_id]
      if branch_id.present?
        @address_to_update =  ::Reports::GenerateAddressUpdate.new(branch_id: branch_id).execute!
      end
  end


  def government_identification_numbers
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Government Identification Numbers" }
    ]

      @branches = Branch.all
      branch_id              = params[:branch_id]
      if branch_id.present?

        @government_identification_numbers = ::Reports::GenerateGovernmentIdentificationNumbers.new(branch_id: branch_id).execute!
      end

  end
  
  def online_loan_application_reports
    @online_application_status = ::LoanApplication::STATUSES
    @online_applications_list  = LoanApplication.joins(:member).where(
                                    "members.branch_id IN (?)", @branches.pluck(:id)
                                  )
    @online_applications = @online_applications_list
    if params[:status].present?
      @status = params[:status]
      @online_applications = @online_applications.where(status: @status)
    end
    if params[:branch_select].present?
      @branch = ReadOnlyBranch.find(params[:branch_select])
      @online_applications = @online_applications.where("members.branch_id": @branch)
    end
    
    if params[:start_date].present?
      @start_date = params[:start_date]
      @online_applications = @online_applications.where(date_applied: @start_date)
    end

    
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date]) 
      @online_applications = @online_applications.where("loan_applications.data ->> 'date_reject' >= ?", @end_date)           
    end

    @online_applications = @online_applications.order("first_name ASC").page(params[:page]).per(15)
    end
   


  def subscriber
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Government Identification Numbers" }
    ]

      @branches = Branch.all
      
      #@subscriber = Member.where("data->'subscription'->>'is_subscribed' = ? and status = ? and branch_id in (?)", "true", "active", @branches)
      branch_id = params[:branch_id]
    
      if branch_id.present?
        @subscriber = Member.where("data->'subscription'->>'is_subscribed' = ? AND status = ? AND branch_id = ?", "true", "active", branch_id).order(Arel.sql("to_date(data->'subscription'->>'subscribe_updated_at', 'YYYY-MM-DD') DESC"), :last_name )
      end

      
      #raise @subscriber.inspect      
      #branch_id              = params[:branch_id]
      #if branch_id.present?

      #  @government_identification_numbers = ::Reports::Subscriber.new(branch_id: branch_id).execute!
      #end

  end

  def monthly_remittance
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Monthly Remittance" }
    ]
  end

  def insured_loans
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Insured Loans" }
    ]
  end

  def member_reports
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Member Reports" }
    ]
  end

  def collections_clip
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Collections CLIP" }
    ]
  end

  def hiip_report
    @subheader_items = [
      { text: "Other Reports" },
      { text: "HIIP Report" }
    ]
  end

  def collections_blip
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Collections BLIP" }
    ]
  end

  def member_dependents
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Member Dependents" }
    ]
  end

  def member_quarterly_reports
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Member Quarterly Reports" }
    ]
  end

  def insurance_quarterly_reports
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Insurance Quarterly Reports" }
    ]
  end

  def member_counts
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Member Counts" }
    ]
  end

  def cic
    @subheader_items = [
      { text: "Other Reports" },
      { text: "CIC" }
    ]
  end

  def monthly_collection
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Monthly Collection" }
    ]
  end

  def summary_of_certificates_and_policies
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Summary of Certificates and Policies" }
    ]
  end

  def personal_documents
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Personal Documents" }
    ]
  end

  def claims
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Claims" }
    ]
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

  def download_excel_insurance_interest
    if params[:start_date].present? and params[:end_date].present?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
    else
      @branch = nil
    end

    filename = "insurance_interest.xlsx"

    excel = Reports::GenerateInsuranceInterestExcel.new(start_date: @start_date, end_date: @end_date, branch: @branch).execute!
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

    excel = Reports::GenerateCollectionsClipReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "collections_clip_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def collections_blip_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]

    excel = Reports::GenerateCollectionsBlipReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "collections_blip_report.xlsx"

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

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def collections_hiip_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]

    excel = Reports::GenerateCollectionsHiipReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "collections_hiip_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def subsidiary_ledger

  end

  def subsidiary_ledger_report
    @as_of = params[:as_of]
    @branch = params[:branch]

    excel = Reports::GenerateSubsidiaryLedgerExcel.new(as_of: @as_of, branch: @branch).execute!
    filename  = "subsidiary_ledger.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def calamity_reports
  end

  def calamity_claim_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]

    excel = Reports::GenerateCalamityClaimsReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "calamity_claim_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def kalinga
  end

  def kalinga_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]

    excel = Reports::GenerateKalingaReportExcel.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "kalinga_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def kbente
  end

  def kbente_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]

    excel = Reports::GenerateKbenteExcelReport.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "kbente_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def kjsp
  end

  def kjsp_reports
    branch = params[:branch]
    start_date = params[:start_date]
    end_date = params[:end_date]

    excel = Reports::GenerateScholarshipExcelReport.new(branch: branch, start_date: start_date, end_date: end_date).execute!
    filename  = "scholarship_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def personal_document
  end

  def personal_document_reports
    start_date = params[:start_date]
    end_date = params[:end_date]
    branch = params[:branch]
    branch_name = Branch.where(id: branch).first.name
    insurance_status = params[:insurance_status]

    excel = Reports::GeneratePersonalDocumentsReportExcel.new(start_date: start_date, end_date: end_date, branch: branch, insurance_status: insurance_status).execute!
    filename  = "#{branch_name}_personal_documents_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def hiip_report_excel
    start_date = params[:start_date]
    end_date = params[:end_date]
    branch = params[:branch]

    excel = Reports::GenerateHiipReportExcel.new(start_date: start_date, end_date: end_date, branch: branch).execute!
    filename  = "hiip_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def claims_processing_time_report
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Claims Processing Time Report" }
    ]
  end

  def claims_processing_time_report_excel
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @branch = params[:branch]

    filename = "claims_processing_time_report.xlsx"

    excel = Reports::GenerateClaimsProcessingTimeReport.new(start_date: @start_date, end_date: @end_date, branch: @branch).execute!
    excel.serialize "#{Rails.root}/tmp/#{filename}"

    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def claims_processing_time_report_summary
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Claims Processing Time Report Summary" }
    ]
  end

  def claims_processing_time_report_summary_excel
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @branch = params[:branch]

    filename = "claims_processing_time_report_summary.xlsx"

    excel = Reports::GenerateClaimsProcessingTimeReportSummary.new(start_date: @start_date, end_date: @end_date, branch: @branch).execute!
    excel.serialize "#{Rails.root}/tmp/#{filename}"

    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def reclassified_report
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Claims Processing Time Report" }
    ]
  end

  def reclassified_report_excel
      # @start_date = params[:start_date]
      # @end_date = params[:end_date]
      @branch = params[:branch]

    filename = "reclassified_report.xlsx"

    excel = Reports::GenerateReclassifiedReport.new(branch: @branch).execute!
    excel.serialize "#{Rails.root}/tmp/#{filename}"

    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def savings_insurance_transfer_reports
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Savings Insurance Transfer Reports" }
    ]
  end

  def savings_insurance_transfer_reports_excel
    if !Settings.activate_microinsurance
      @savings_subtype = params[:savings_subtype]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @insurance_subtype = params[:insurance_subtype]
      @branch = params[:branch_id]
      @status = params[:status]
      @branch_name = Branch.where(id: @branch).first.name

      excel = Reports::GenerateSavingsInsuranceTransferReports.new(start_date: @start_date, end_date: @end_date, branch: @branch, insurance_subtype: @insurance_subtype, savings_subtype: @savings_subtype, status: @status).execute!
      filename  = "#{@branch_name}Savings Insurance Transfer Report.xlsx"

      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    else
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @insurance_subtype = params[:insurance_subtype]
      @payment_subtype = params[:payment_subtype]
      @branch = params[:branch_id]
      @status = params[:status]
      @branch_name = Branch.where(id: @branch).first.name

      excel = Reports::GenerateSavingsInsuranceTransferReports.new(start_date: @start_date, end_date: @end_date, branch: @branch, insurance_subtype: @insurance_subtype, payment_subtype: @payment_subtype, status: @status).execute!
      filename  = "#{@branch_name} Savings Insurance Transfer Report.xlsx"

      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end
  end

  def insurance_loan_bundle_reports
    @subheader_items = [
      { text: "Other Reports" },
      { text: "KDAKILA Reports" }
    ]
  end

  def insurance_loan_bundle_reports_excel
    @start_date         = params[:start_date]
    @end_date           = params[:end_date]
    @approval_date_from = params[:approval_date_from]
    @approval_date_to   = params[:approval_date_to]
    @branch_name        = Branch.where(id: @branch).first.name
    @status             = params[:status]

    excel = Reports::GenerateInsuranceLoanBundleReports.new(start_date: @start_date, end_date: @end_date, approval_date_from: @approval_date_from, approval_date_to: @approval_date_to , branch: @branch, status: @status).execute!
    filename  = "#{@branch_name}Savings Insurance Transfer Report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  end


  def claim_generate_report
    claim_type = params[:claim_type]
    start_date = params[:start_date]
    end_date = params[:end_date]
    branch = params[:branch]

    if claim_type == "BLIP"
      excel = Reports::GenerateBlipExcelReport.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "blip_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    elsif claim_type == "CLIP"
      excel = Reports::GenerateClipExcelReport.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "clip_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    elsif claim_type == "CALAMITY ASSISTANCE"
      excel = Reports::GenerateCalamityClaimsReportExcel.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "calamity_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    elsif claim_type == "HIIP"
      excel = Reports::GenerateHiipExcelReport.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "hiip_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    elsif claim_type == "K-KALINGA"
      excel = Reports::GenerateKalingaExcelReport.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "kalinga_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    elsif claim_type == "K-BENTE"
      excel = Reports::GenerateKbenteExcelReport.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "kbente_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    elsif claim_type == "KUYA JUN SCHOLARSHIP PROGRAM"
      excel = Reports::GenerateScholarshipExcelReport.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "scholarship_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    else
      excel = Reports::GenerateClaimsExcelReport.new(start_date: start_date, end_date: end_date, branch: branch).execute!
      filename  = "claims_report.xlsx"
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end
  end


  def insurance_interest
    @subheader_items = [
      { text: "Other Reports" },
      { text: "Insurance Interest" }
    ]
  end
end
