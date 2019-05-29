class ProcessIcpr < ApplicationJob
  queue_as :default

  def perform(args)
    record  = DataStore.find(args[:id])
    branch  = Branch.find(record.meta.with_indifferent_access[:branch_id])
    start_date  = record.meta.with_indifferent_access[:start_date].to_date
    end_date    = record.meta.with_indifferent_access[:end_date].to_date
    equity_rate = record.meta.with_indifferent_access[:equity_rate].to_f
    
    record.update!(status: "processing")

    begin
      config  = {
        id: record.id,
        start_date: start_date,
        end_date: end_date,
        equity_rate: equity_rate,
        branch: branch
      }

      data_store  = DataStores::SaveIcpr.new(
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
