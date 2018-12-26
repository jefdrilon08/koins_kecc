module Loaders
  class UpdateLoanProductsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      @data[:loan_products].each do |o|
        loan_product  = LoanProduct.where(id: o[:id]).first

        if loan_product.blank?
          loan_product  = LoanProduct.new
        end

        loan_product.id                     = o[:id]
        loan_product.name                   = o[:name]
        loan_product.max_loan_amount        = o[:max_loan_amount]
        loan_product.min_loan_amount        = o[:min_loan_amount]
        loan_product.denomination           = o[:denomination]
        loan_product.insured                = o[:insured]
        loan_product.is_entry_point         = o[:is_entry_point]
        loan_product.monthly_interest_rate  = o[:monthly_interest_rate]
        loan_product.priority               = o[:priority]
        loan_product.data                   = o[:data]

        loan_product.save!
      end
    end
  end
end
