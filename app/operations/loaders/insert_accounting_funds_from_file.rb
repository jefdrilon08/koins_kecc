module Loaders
  class InsertAccountingFundsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      AccountingFund.transaction do
        columns = [
          :id,
          :name
        ]

        AccountingFund.import columns, @data[:accounting_funds]
      end
    end
  end
end
