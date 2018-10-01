module Loaders
  class InsertAccountingEntriesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      AccountingEntry.transaction do
        columns = [
          :id, 
          :date_prepared,
          :date_posted,
          :branch_id,
          :book,
          :reference_number,
          :particular,
          :approved_by,
          :prepared_by,
          :status,
          :data
        ]

        AccountingEntry.import columns, @data[:accounting_entries], validate: false
      end
    end
  end
end
