class ProcessApproveInvoluntaryPayment < ApplicationJob
    queue_as :default
  
    def perform(args)
      record = DataStore.find(args[:data_store])
      user = User.find(args[:user])
  
      begin
        config = {
          record: record,
          user: user
        }
  
        # Approve the billing for write-off collection
        record = ::InvoluntaryPayment::Approve.new(config: config).execute!
        record.update!(status: "approved")
  
      rescue StandardError => e
        # Capture more detailed information for debugging
        error_details = {
          status: "error",
          data: {
            exception_class: e.class.to_s,
            exception_message: e.message,
            application_trace: Rails.backtrace_cleaner.clean(e.backtrace),
            full_trace: e.backtrace
          }
        }
  
        record.update!(error_details)
        
        # Optional: You might want to re-raise the error if you want it to be logged by the job system
        raise e
      end
    end
  end
  