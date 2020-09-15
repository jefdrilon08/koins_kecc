namespace :generate do
  task :cutoff_reports => :environment do
    ProcessCutoffReports.perform_later({})
  end
end
