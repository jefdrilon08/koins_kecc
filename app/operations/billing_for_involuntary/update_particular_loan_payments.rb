module BillingForInvoluntary
    class UpdateParticularLoanPayments
        def initialize(config:)
            @data_store = DataStore.find(config[:data_store_id])
            @data = @data_store.data.with_indifferent_access
            @particular = config[:particular]
        end
        def execute!
            
            @data[:accounting_entry_loan_payments][:particular] = @particular
            @data_store.update(data: @data)
            @data_store
        end
    end
end