class ProcessYearEndClosing < ApplicationJob
  queue_as :default

  def perform(args)
    record        = DataStore.find(args[:id])
    user          = User.find(args[:user_id])
    branch        = Branch.find(record.meta.with_indifferent_access[:branch_id])
    closing_date  = record.meta.with_indifferent_access[:closing_date].to_date
    year          = closing_date.year 
    
    record.update!(status: "processing")

    begin
      config  = {
        id: record.id,
        user: user,
        closing_date: closing_date,
        year: year,
        branch: branch
      }

      data_store  = DataStores::SaveYearEndClosing.new(
                      config: config
                    ).execute!

    rescue Exception => e
      record.update!(
        status: "error",
        data: {
          exception: e,
          application_trace: Rails.backtrace_cleaner.clean(e.backtrace)
        }
      )
    end
  end
end
