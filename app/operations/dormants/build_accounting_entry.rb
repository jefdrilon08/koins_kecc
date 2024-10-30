module Dormants
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
      @accounting_entry[:journal_entries]         = [] 

      @accounting_entry[:debit_journal_entries].each do |j|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }  
      end

      @accounting_entry[:credit_journal_entries].each do |j|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }  
      end

    end
    
    def build_credit_journal_entries!
      journal_entries           = []
      accounting_code        = AccountingCode.find("22e9409a-b0e5-4aca-bdc9-2f22dd8e9889")
      total_payment             = @header[0]['total_payment'].to_f

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: total_payment.to_f
        }

      journal_entries
    end

    def build_debit_journal_entries!
      journal_entries           = []
      accounting_code        = AccountingCode.find("b7c23e58-e44e-46ae-a3ec-b5081d6eed32")
      total_payment             = @header[0]['total_payment'].to_f

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: total_payment.to_f
        }

      journal_entries
    end

  end
end
 
