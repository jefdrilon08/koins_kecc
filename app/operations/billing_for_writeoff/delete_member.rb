module BillingForWriteoff
  class DeleteMember
   
   def initialize(config: )
  
    @config = config
    @data_store = @config[:data_store]
    @member_id = @config[:member_id]
    @loan_id = @config[:loan_id]
    @data = DataStore.find(@data_store[:id]).data.with_indifferent_access
   end

   def execute!
        @data[:record].each_with_index do |value, index|
          if  @data[:record].count == 1
                @data[:record].delete_at(index)
                @data[:accounting_entry][:debit_journal_entries]  = []
                @data[:accounting_entry][:credit_journal_entries] = []
                @data[:accounting_entry][:journal_entries]        = []
          else
              if value[:loan][:loan_id] == @loan_id and value[:member][:id] == @member_id
                @data[:record].delete_at(index)
                data_entry = ::BillingForWriteoff::BuildAccountingEntry.new(config: {
                data: @data
                }).execute!
                @data[:accounting_entry] = data_entry
              end
          end
        end 
        @data_store[:data]= @data
        @data_store.save!
   end
  

  end
end
