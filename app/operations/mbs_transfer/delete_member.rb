module MbsTransfer
  class DeleteMember
    def initialize(config:)
      @config = config
      @data_store = DataStore.find(@config[:data_store_id])
      @records = @data_store.data.with_indifferent_access
      @member_id = config[:member_id]

      
    end
    def execute!
      @records[:record].each_with_index do |rec,index|

     
        
        if @records[:record].count == 1 
          @records[:record].delete_at(index)
          @records[:accounting_entry][:debit_journal_entries] = []
          @records[:accounting_entry][:credit_journal_entries]=[]
          @records[:accounting_entry][:journal_entries]= []
          @records[:accounting_entry][:particular] = ""
          

          @records[:header].each_with_index do |h,index|
            if h["total_amount"].to_f > 0.0
              @records[:header][index] = {
                name: h["name"],
                accounting_code_id: h[:accounting_code_id],
                total_amount: 0.0
              }
            end
          end
          
        else
          if rec[:member_id] == @member_id
            #
            
            member_share_cap = rec[:total_add_capital]

            member_account = []

            rec[:records].each do | mem_rec|
              if mem_rec[:amount] > 0.0
                member_account << mem_rec
              end
            end
            
            @records[:header].each_with_index do |head,index|
              member_account.each do |mem|
                if head["accounting_code_id"] == mem["accounting_code_id"]

                  header_amount = head[:total_amount].to_f - mem[:amount].to_f
                  @records[:header][index] = {
                    name: head["name"],
                    accounting_code_id: head["accounting_code_id"],
                    total_amount: header_amount.to_f
                  }
                end
              end

              if head["accounting_code_id"] == "370f5e4f-e4c8-454e-90b2-17919cc5ef92"
                share_cap_total_amount = head[:total_amount].to_f - member_share_cap.to_f
                @records[:header][index] = {
                  name: head["name"],
                  accounting_code_id: head["accounting_code_id"],
                  total_amount: share_cap_total_amount.to_f
                }
              end
            end
            @records[:record].delete_at(index)
            @data_store.update!(data: @records)
            
            config = {
              data_store_id: @data_store.id
            }
            accounting_entry = ::AdditionalShare::BuildAccountingEntry.new(config: config).execute!

          end
        end

      end
      @data_store.update!(data: @records)
      @data_store
    end
  end
end