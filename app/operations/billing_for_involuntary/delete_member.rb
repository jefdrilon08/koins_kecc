module BillingForInvoluntary
    class DeleteMember
        def initialize(config:)
            @data_store = DataStore.find(config[:data_store_id])
            @data = @data_store.data.with_indifferent_access
            @member_id = config[:member_id]
        end
        
        def execute!
            @data[:records].each_with_index do |rec,index|
                if rec[:member_id] == @member_id
                    @data[:records].delete_at(index)
                end         
            end

            config = {
                records: @data[:records],
                accounting_entry_transfer_savings: @data[:accounting_entry_transfer_savings],
                accounting_entry_loan_payment: @data[:accounting_entry_loan_payments]
            }
            @data[:accounting_entry_transfer_savings] = ::BillingForInvoluntary::BuildAccountingEntryTransferSavings.new(config: config).execute!
            @data[:accounting_entry_loan_payments] = ::BillingForInvoluntary::BuildAccountingEntryLoanPayments.new(config: config).execute!
            
            @data_store[:data] = @data
            @data_store.save!
            @data_store
        end
    end
end