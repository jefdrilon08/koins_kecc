module Loaders
  class InsertMemberAccountTransactionsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      AccountTransaction.transaction do
        columns = [
          :id,
          :subsidiary_id,
          :subsidiary_type,
          :amount,
          :transaction_type,
          :transacted_at,
          :status,
          :data
        ]

        AccountTransaction.import columns, @data[:account_transactions], validate: false
      end
    end
  end
end
