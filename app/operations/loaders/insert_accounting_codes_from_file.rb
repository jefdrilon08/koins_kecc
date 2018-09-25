module Loaders
  class InsertAccountingCodesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      AccountingCode.transaction do
        columns = [
          :id, 
          :name, 
          :code, 
          :category, 
          :data
        ]

        AccountingCode.import columns, @data[:accounting_codes]
      end
    end
  end
end
