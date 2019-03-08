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

  def index
    @announcements = Announcement.all
  end

  def login
    render 'pages/login', layout: 'plain'
  end

  def export_tools
  end
end
