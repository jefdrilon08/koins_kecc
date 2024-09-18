module InvoluntaryPayment
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
      journal_entries = []
      @header.each do |header|
        if !header[:loan_id].nil?
          acc = Settings.loan_products.select { |l| l[:loan_product_id] == header[:loan_id] }.first
          rec_acc_code = AccountingCode.find(acc[:receivable_accounting_code_id]) 
          int_acc_code = AccountingCode.find(acc[:interest_receivable_accounting_code_id]) 

          if header[:principal_amount] > 0
            journal_entries << {
              accounting_code_id: rec_acc_code[:id],
              code: rec_acc_code[:code],     
              name: rec_acc_code[:name],     
              amount: header[:principal_amount].to_f   
            }
          end
          if header[:interest_amount] > 0
            journal_entries << {
              accounting_code_id: int_acc_code[:id],
              code: int_acc_code[:code],     
              name: int_acc_code[:name],     
              amount: header[:interest_amount].to_f   
            }
          end
        end
      end
      journal_entries
    end

    def build_debit_journal_entries!
      journal_entries = []
      branch_accounting_code_id = Settings.branch_accounting_codes.select { |o| o["branch_id"] == @branch_id }.first["cash_in_bank_accounting_code_id"]
      accounting_code = AccountingCode.find(branch_accounting_code_id)

      # Define loans based on @header
      loans = @header.select { |h| h[:loan_id].present? }
      total_payment = loans.sum { |l| l[:total_amount].to_f }

      # Calculate total cash payment directly from total_payment
      total_cash_payment = total_payment

      if total_cash_payment > 0
        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: total_cash_payment.to_f
        }
      end 
      journal_entries
    end
  end
end