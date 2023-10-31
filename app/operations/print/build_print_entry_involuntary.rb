module Print
    class BuildPrintEntryInvoluntary
        include ActionView::Helpers::NumberHelper
        def initialize(config:)
            
            @data_store = DataStore.find(config)
            @datastore_data = @data_store.data.with_indifferent_access
            @data = {}

            @data[:company_name]          = Settings.company_name
            @data[:company_address]       = Settings.company_address
            @data[:branch]          = @data_store.meta["branch_name"]
            @data[:prepared_by] = @data_store.meta["prepared_by"]["name"]

            
            
        end
        def execute!
            @datastore_data[:accounting_entry_transfer_savings].each do |ats|
                
            end




            raise @data.inspect
        end
    end
end