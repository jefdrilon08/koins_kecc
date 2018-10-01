module Loaders
  class InsertJournalEntriesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      JournalEntry.transaction do
        columns = [
          :id, 
          :post_type,
          :accounting_code_id,
          :accounting_entry_id,
          :amount,
          :data
        ]

        JournalEntry.import columns, @data[:journal_entries], validate: false
      end
    end
  end
end
