class ProcessApproveBillingForWriteoffCollections < ApplicationJob 
  queue_as :default
  def perform(args)
    record    = args[:data_store]
    user      = args[:user]
    raise record.inspect
  end
end
