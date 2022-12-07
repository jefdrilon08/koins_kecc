module MbsTransfer
  class BuildAccountingEntry
    def initialize(config:)
      @config           = config      
      @data_store_id    = @config[:data_store_id]

      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @header           = @data[:header]
      @accounting_entry = @data[:accounting_entry]
      @branch_id        = @data_store.meta['branch_id']
    end
    
    def execute!
      build_entry!
      @data_store.update(data: @data)
    end
    def build_entry!
      @accounting_entry[:credit_journal_entries]  = build_credit_journal_entries!
      @accounting_entry[:debit_journal_entries]   = build_debit_journal_entries!

      @accounting_entry[:journal_entries] = [] 
      
      @accounting_entry[:debit_journal_entries].each do |j|
      @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: "#{j[:code]} - #{j[:name]}",
          amount: j[:amount]
        }  
      end

      @accounting_entry[:credit_journal_entries].each do |j|
      @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: "#{j[:code]} - #{j[:name]}",
          amount: j[:amount]
        }  
      end


    end
     
    def build_debit_journal_entries!
     journal_entries = []
      @header.each do |header|
          if header['name'] != "MBS"
            rec_acc_code = AccountingCode.find(header[:accounting_code_id]) 
            if header[:total_amount] > 0
              journal_entries << {
                accounting_code_id: rec_acc_code[:id],
                code:  rec_acc_code[:code],     
                name:  rec_acc_code[:name],     
                amount: header[:total_amount].to_f   
              }
            end
          end
        end
      journal_entries
    end

    def build_credit_journal_entries!
     journal_entries = []
      @header.each do |header|
          if header['name'] == "MBS"
            rec_acc_code = AccountingCode.find(header[:accounting_code_id]) 
            if header[:total_amount] > 0
              journal_entries << {
                accounting_code_id: rec_acc_code[:id],
                code:  rec_acc_code[:code],     
                name:  rec_acc_code[:name],     
                amount: header[:total_amount].to_f   
              }
            end
          end
        end
      journal_entries
     end


  end
end
 
