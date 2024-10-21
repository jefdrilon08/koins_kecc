class ProcessGenerateDormant < ApplicationJob
  queue_as :default

  def perform(config)
    dormants_fee = ::Dormants::Create.new(config: config).execute!
    
    data_store_id = dormants_fee[:id]
    config[:data_store_id] = data_store_id
    
    ::Dormants::BuildAccountingEntry.new(config: config).execute!
  end
end
