module BillingForInvoluntary
  class BuildAccountingEntryTransferSavings
    def initialize(config:)
      @config = config      
      @accounting_entry = @config[:accounting_entry_transfer_savings]
      @records = @config[:records]
      @savings_accounting_codes   = Settings.savings_accounting_codes
      @equity_accounting_codes    = Settings.equity_accounting_codes
    end
    
    def execute!
      @accounting_entry[:debit_journal_entries] = []
      @accounting_entry[:credit_journal_entries]  = []
      @accounting_entry[:journal_entries] = []
      @accounting_entry[:debit_journal_entries] = build_debit_journal_entries!
      @accounting_entry[:credit_journal_entries] = build_credit_journal_entries!
      
      @accounting_entry[:debit_journal_entries].each do |adbj|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].round(2)
        }
      end

      @accounting_entry[:credit_journal_entries].each do |adbj|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].round(2)
        }
      end
      @accounting_entry
    end

    private
      def build_debit_journal_entries!
        journal_entries = []
        @records.each do |rec|
          
          rec[:member_accounts].each do |ma|
            if ma[:account_type] == "EQUITY"
              @equity_accounting_codes.each do |eqac|
                if eqac[:equity_type] == ma[:account_subtype]
                  deposit_accounting_code_id = eqac[:deposit_accounting_code_id]
                  acc_code = AccountingCode.find(deposit_accounting_code_id)
                  journal_entries << {
                    accounting_code_id: acc_code.id,
                    code: acc_code.code,
                    name: acc_code.name,
                    amount: ma[:balance].to_f
                  }
                end
              end
            end

            if ma[:account_type] == "SAVINGS" and ma[:account_subtype] != "K-IMPOK"
              @savings_accounting_codes.each do |sav|
                if sav[:savings_type] == ma[:account_subtype]
                  deposit_accounting_code_id = sav[:deposit_accounting_code_id]
                  acc_code = AccountingCode.find(deposit_accounting_code_id)
                  journal_entries << {
                    accounting_code_id: acc_code.id,
                    code: acc_code.code,
                    name: acc_code.name,
                    amount: ma[:balance].to_f
                  }
                end
              end
            end
            
  
          end
        end

        if journal_entries.count > 1
          journal = journal_entries.group_by {|item| [item[:accounting_code_id]]}.values.flat_map{|items| items.first.merge(amount: items.sum{|h| h[:amount]})}
          journal_entries = journal
        end
        journal_entries
      end

      def build_credit_journal_entries!
        journal_entries = []
        

        @records.each do |rec|
         
          credit_amount = 0.0
          rec[:member_accounts].each do |ma|
            
            if ma[:account_subtype] != "K-IMPOK"
              credit_amount += ma[:balance]
            end
          end

          rec[:member_accounts].each do |maa|
            if maa[:account_subtype] == "K-IMPOK" and maa[:account_type] == "SAVINGS"
              @savings_accounting_codes.each do |sav|
                
                if sav[:savings_type] == maa[:account_subtype]
                  deposits_accounting_code = sav[:deposit_accounting_code_id]
                  acc_code = AccountingCode.find(deposits_accounting_code)
                  journal_entries << {
                    accounting_code_id: acc_code.id,
                    code: acc_code.code,
                    name: acc_code.name,
                    amount: credit_amount.round(2).to_f
                  }
                end
              end
            end
          end
        end
        #raise journal_entries.inspect
       
        if journal_entries.count > 1
          journal= journal_entries.group_by { |item|
            [item[:accounting_code_id]]
          }.values.flat_map{|items| items.first.merge(amount: items.sum{|h| h[:amount]})}
          journal_entries = journal
        end
       
       journal_entries
      end
  
  end
end