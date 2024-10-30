class ProcessApproveDormants < ApplicationJob
  queue_as :default

  def perform(args)
    record = DataStore.find(args[:data_store])
    user = User.find(args[:user])
    
    if record.nil?
      Rails.logger.error("DataStore record not found with ID: #{args[:data_store]}")
      return
    end

    begin
      config = {
        record: record,
        user: user
      }
       # Approve the Dormant
       record = ::Dormants::Approve.new(config: config).execute!
       
       # Update the record status after processing
       record.update!(status: "approved")
 
     rescue StandardError => e
       error_details = {
         status: "error",
         data: {
           exception_class: e.class.to_s,
           exception_message: e.message,
           application_trace: Rails.backtrace_cleaner.clean(e.backtrace),
           full_trace: e.backtrace
         }
       }
 
       # Capture the error in the record and update status
       record.update!(error_details)
       Rails.logger.error(error_details) # Log the error for debugging
     end
   end
 end