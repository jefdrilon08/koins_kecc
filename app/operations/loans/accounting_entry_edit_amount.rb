module Loans
  class AccountingEntryEditAmount
    def initialize(config:)
      @config                     = config
      @loan                       = Loan.find(@config[:loan_id])
      @amount                     = @config[:amount].to_f.round(1)
      @accounting_code_id         = @config[:accounting_code_id]
      @loan_data                  = @loan.data.with_indifferent_access
    end

    def insert_amount_by_code(accounting_code_id, amount)
      return unless amount.present?
    
      debit_entry = @loan_data['accounting_entry']['debit_journal_entries']
        .find { |entry| entry['accounting_code_id'] == accounting_code_id }
      debit_entry['amount'] = amount if debit_entry
    
      credit_entry = @loan_data['accounting_entry']['credit_journal_entries']
        .find { |entry| entry['accounting_code_id'] == accounting_code_id }
      credit_entry['amount'] = amount if credit_entry
    
      journal_entry = @loan_data['accounting_entry']['journal_entries']
        .find { |entry| entry['accounting_code_id'] == accounting_code_id }
      journal_entry['amount'] = amount if journal_entry
    end
    

    def execute!
      insert_amount_by_code(@accounting_code_id, @amount)
      @loan.update!(data: @loan_data)
    end
  end
end
