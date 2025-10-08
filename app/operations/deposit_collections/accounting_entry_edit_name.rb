module DepositCollections
  class AccountingEntryEditName
    def initialize(config:)
      @config               = config
      @deposit_collection   = DepositCollection.find(@config[:id])
      @data                 = @deposit_collection.data.with_indifferent_access
      @accounting_code_id   = @config[:accounting_code_id]
      @accounting_code_new  = @config[:accounting_code_new]
    end

    def edit_accounting_name(accounting_code_id)
      Rails.logger.info "Received config: #{@config.inspect}"

      accounting_code_new = AccountingCode.find(@accounting_code_new)

      ae = @data['accounting_entry'] || {}

      # ----- DR entries -----
      debit_entry = Array.wrap(ae['debit_journal_entries'])
                         .find { |entry| (entry['accounting_code_id'] || entry[:accounting_code_id]) == accounting_code_id }
      if debit_entry
        debit_entry['code']               = accounting_code_new.code
        debit_entry['name']               = accounting_code_new.name
        debit_entry['accounting_code_id'] = accounting_code_new.id
      end

      # ----- CR entries -----
      credit_entry = Array.wrap(ae['credit_journal_entries'])
                          .find { |entry| (entry['accounting_code_id'] || entry[:accounting_code_id]) == accounting_code_id }
      if credit_entry
        credit_entry['code']               = accounting_code_new.code
        credit_entry['name']               = accounting_code_new.name
        credit_entry['accounting_code_id'] = accounting_code_new.id
      end

      journal_entry = Array.wrap(ae['journal_entries'])
                           .find { |entry| (entry['accounting_code_id'] || entry[:accounting_code_id]) == accounting_code_id }
      if journal_entry
        journal_entry['accounting_code_name'] = accounting_code_new.name
        journal_entry['accounting_code_id']   = accounting_code_new.id
      end

      @deposit_collection.update!(data: @data)
    end

    def execute!
      edit_accounting_name(@accounting_code_id)
    end
  end
end
