module Loaders
  class InsertAccountTransactionCollectionsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      AccountTransactionCollection.transaction do
        columns = [
          :id,
          :or_number,
          :total_amount,
          :center_id,
          :branch_id,
          :status,
          :transacted_at,
          :collection_type,
          :data
        ]

        AccountTransactionCollection.import columns, @data[:account_transaction_collections]
      end
    end
  end
end
