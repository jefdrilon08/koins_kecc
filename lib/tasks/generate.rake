namespace :generate do
  task :cutoff_reports => :environment do
    user_id = ENV["USER_ID"]

    ProcessCutoffReports.perform_later({ user_id: user_id })
  end
end
