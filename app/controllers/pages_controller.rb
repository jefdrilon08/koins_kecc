class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:login]

  def download_backup
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
  end

  def download_file
    filename = params[:filename]
    destination_file = "#{Rails.root}/tmp/#{filename}"

    send_file destination_file, filename: filename
  end

  def index
    @announcements = Announcement.all
  end

  def login
    render 'pages/login', layout: 'plain'
  end

  def insurance_exit_age_members 
    @members = Member.active.where("DATE(date_of_birth) <= ? AND member_type = ? AND branch_id IN (?) ", 774.months.ago, "Regular", @branches.pluck(:id)).order("branch_id ASC") 
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

  def upload_deposit
  end

  def import_members
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
end
