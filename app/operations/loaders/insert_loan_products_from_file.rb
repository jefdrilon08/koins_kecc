module Loaders
  class InsertLoanProductsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      LoanProduct.transaction do
        columns = [
          :id,
          :name,
          :max_loan_amount,
          :min_loan_amount,
          :denomination,
          :insured,
          :is_entry_point,
          :monthly_interest_rate
        ]

        LoanProduct.import columns, @data[:loan_products]
      end
    end
  end
end
