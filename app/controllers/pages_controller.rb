class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:login]

  def index
    @pending_members_count = Member
      .pending
      .where(branch_id: @branches.pluck(:id))
      .count

    @payload = {
      username: current_user.username,
      roles: current_user.roles
    }
  end

  def download_backup
    if user_signed_in? and current_user.roles.include?("MIS")
      destination_directory = "#{Rails.root}/db_backup"
      filename = "#{Time.now.to_i}-backup-#{ENV['RAILS_ENV'] ||= 'development'}.dump"
      destination_file = "#{destination_directory}/#{filename}"

      pw = ::ActiveRecord::Base.connection_config[:password]
      host = ::ActiveRecord::Base.connection_config[:host]
      username = ::ActiveRecord::Base.connection_config[:username]
      db = ::ActiveRecord::Base.connection_config[:database]

      cmd = "PGPASSWORD=#{pw} pg_dump --host #{host} --username #{username} --verbose --clean --no-owner --no-acl --format=c #{db} > #{destination_file}"
      `#{cmd}`
      send_file destination_file, filename: filename
    else
      redirect_to root_path
    end
  end

  def download_file
    filename = params[:filename]
    destination_file = "#{Rails.root}/tmp/#{filename}"

    send_file destination_file, filename: filename
  end

  def finance
    render "dashboard/finance"
  end

  def insights
    @end_date   = Date.today
    @start_date = @end_date - 7.days
  end

  def login
    render 'pages/login', layout: 'plain'
  end

  def insurance_exit_age_members 
    @members = Member.where("DATE(date_of_birth) <= ? AND member_type = ? AND status = ? AND branch_id IN (?) ", 774.months.ago, "Regular", "active", @branches.pluck(:id)).order("branch_id ASC, center_id ASC, last_name ASC") 
  
    if params[:branch_id].present?
      @branch_id = params[:branch_id]
      @members = @members.where(branch_id: @branch_id)
    end

    @subheader_items = [
      {
        text: "Microinsurance"
      },
      {
        text: "Members for Exit Age"
      }
    ]

    @subheader_side_actions = [
      {
        link: download_exit_age_path,
        class: "fa fa-download",
        text: "Download"
      }
    ]
  end

  def lapsed_members
    @members = Member
      .includes(:branch, :center)
      .where(status: "active", insurance_status: "lapsed", branch_id: @branches.pluck(:id))
      .order("branches.name ASC, centers.name ASC, last_name ASC")

    # @members = Insurance::FetchActiveLapsed.new(branches: @branches).execute!
    # @members.order("branches.name ASC, centers.name ASC, last_name ASC")

    if params[:branch_id].present?
      @branch_id = params[:branch_id]
      @members = @members.where(branch_id: @branch_id)
    end

    @members  = @members.order("last_name ASC").page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      {
        text: "Microinsurance"
      },
      {
        text: "Lapsed Members"
      }
    ]

    @subheader_side_actions = [
    ]
  end

  def members_for_reinsurance
    @members = Insurance::FetchMembersForReinsurance.new.execute!

    @subheader_items = [
      {
        text: "Microinsurance"
      },
      {
        text: "Members for Reinsurance"
      }
    ]

    @subheader_side_actions = [
    ]
  end

  def download_exit_age
    @members = Member.active.where("DATE(date_of_birth) <= ? AND member_type = ? AND branch_id IN (?) ", 774.months.ago, "Regular", @branches.pluck(:id)).order("branch_id ASC") 
    excel     = Members::GenerateInsuranceExitAgeReportExcel.new(
                  members: @members
                ).execute!

    filename  = "insurance_exit_age_members.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" 
  end

  def export_tools
  end

  def billing_per_center
    @centers  = @branches.first.centers.order("name ASC")
  end

  def upload_deposit
  end

  def upload_insurance_withdrawal
  end

  def upload_fund_transfer
  end

  def import_members
  end

  def import_beneficiaries
  end

  def import_legal_dependents
  end

  def import_insurance_accounts
  end

  def import_insurance_account_transactions
    @records  = DataStore.import_insurance_account_transactions.order("created_at DESC").page(params[:page]).per(35)
  end

  def seriatim
    @subheader_items = [
      {
        text: "Seriatim Report"
      }
    ]

    @subheader_side_actions = []
  end

  def seriatim_report
    branch = params[:branch]
    as_of = params[:as_of]
  
    excel = Reports::GenerateSeriatimReportExcel.new(
                                                branch: branch,
                                                as_of: as_of
                                                ).execute!

    filename  = "seriatim_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def validations
    @subheader_items = [
      {
        text: "Validations Report"
      }
    ]

    @subheader_side_actions = []
  end

  def validations_report
    branch = params[:branch]
    status = params[:status]
    start_date = params[:start_date]
    end_date = params[:end_date]
  
    excel = MemberAccountValidations::GenerateValidationsReportExcel.new(
                                                branch: branch,
                                                status: status,
                                                start_date: start_date,
                                                end_date: end_date
                                                ).execute!

    filename  = "#{status}_validations_report.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def daily_report_insurance_account_status
    @subheader_items = [
      {
        text: "Insurance Account Status"
      }
    ]

    @subheader_side_actions = []
  end

  def daily_report_insurance_account_status_excel
    branch = params[:branch]
    excel = Pages::GenerateDailyReportInsuranceAccountStatus.new(
                                                branch: branch
                                                ).execute!

    filename  = "insurance_account_status.xlsx"

    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

end
