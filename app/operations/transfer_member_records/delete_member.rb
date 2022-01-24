module TransferMemberRecords
  class DeleteMember
   
   def initialize(config: )
  
    @transfer_member_record = TransferMemberRecord.find(config[:transfer_member_records])
    @tfm_records = @transfer_member_record.data.with_indifferent_access
    @member_id = config[:member_id]
   end

   def execute!
    
        @tfm_records[:records].each_with_index do |value, index|
            if  @tfm_records[:records].count == 1
                  @tfm_records[:records].delete_at(index)
                  @tfm_records[:accounting_entry_from][:debit_journal_entries]  = []
                  @tfm_records[:accounting_entry_from][:credit_journal_entries] = []
                  @tfm_records[:accounting_entry_from][:journal_entries]        = []

                  @tfm_records[:accounting_entry_to][:debit_journal_entries]  = []
                  @tfm_records[:accounting_entry_to][:credit_journal_entries] = []
                  @tfm_records[:accounting_entry_to][:journal_entries]        = []
            else
               if value[:member][:id] == @member_id
                @tfm_records[:records].delete_at(index)
                accounting_entry_from = ::TransferMemberRecords::BuildAccountingEntryFrom.new(config:{
                                          accounting_entry_from:  @tfm_records[:accounting_entry_from], 
                                          record: @tfm_records[:records],
                                          transfer_member_records: @transfer_member_record,
                                          accounting_entry_to:  @tfm_records[:accounting_entry_to]
                                          }).execute!
                accounting_entry_to =  ::TransferMemberRecords::BuildAccountingEntryTo.new(config:{
                                          accounting_entry_from:  @tfm_records[:accounting_entry_from], 
                                          record: @tfm_records[:records],
                                          transfer_member_records: @transfer_member_record,
                                          accounting_entry_to:  @tfm_records[:accounting_entry_to]
                                          }).execute!

                @tfm_records[:accounting_entry_from] = accounting_entry_from
                @tfm_records[:accounting_entry_to] = accounting_entry_to
               end
            end

        end
        @transfer_member_record[:data] = @tfm_records
        @transfer_member_record.save!   
   end
  

  end
end
