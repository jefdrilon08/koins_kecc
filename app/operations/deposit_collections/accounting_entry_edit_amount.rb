# app/operations/deposit_collections/accounting_entry_edit_amount.rb
module DepositCollections
  class AccountingEntryEditAmount
    def initialize(config:)
      @config             = config
      @deposit_collection = DepositCollection.find(@config[:id])
      @amount             = @config[:amount].to_f.round(1)  
      @accounting_code_id = @config[:accounting_code_id]
      @data               = @deposit_collection.data.with_indifferent_access
    end

    def insert_amount_by_code(accounting_code_id, amount)
      return unless amount.present?

      ae = @data['accounting_entry'] || {}

      # DR
      debit_entry = Array.wrap(ae['debit_journal_entries'])
                         .find { |e| e['accounting_code_id'] == accounting_code_id }
      debit_entry['amount'] = amount if debit_entry

      # CR
      credit_entry = Array.wrap(ae['credit_journal_entries'])
                          .find { |e| e['accounting_code_id'] == accounting_code_id }
      credit_entry['amount'] = amount if credit_entry

      journal_entry = Array.wrap(ae['journal_entries'])
                           .find { |e| e['accounting_code_id'] == accounting_code_id }
      journal_entry['amount'] = amount if journal_entry
    end

    def execute!
      insert_amount_by_code(@accounting_code_id, @amount)
      @deposit_collection.update!(data: @data)
    end
  end
end
