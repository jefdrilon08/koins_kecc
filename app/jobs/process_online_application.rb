class ProcessOnlineApplication < ApplicationJob
  queue_as :default

  def perform(args)
    begin
      online_application  = OnlineApplication.find(args[:id])
      user                = ReadOnlyUser.find(args[:user_id])

      cmd = ::OnlineApplications::Process.new(
              online_application: online_application,
              branch: branch,
              center: center,
              user: user
            )

      cmd.execute!
    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\r\n"))
      Rollbar.error(e)
    end
  end
end
