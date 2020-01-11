# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

#every :day, at: '6pm' do
#  rake "adjust:update_member_insurance_status"
#end
#
#every :day, at: '6am' do
#  rake "finance:autorenew_time_deposit_accounts"
#end

set :output, "#{Rails.root}/log/cron.log"

#every :day, at: '1am' do
every 1.minutes do
  rake "adjust:set_max_active_date"
  #rake "adjust:update_insurance_status"
end

# Learn more: http://github.com/javan/whenever
