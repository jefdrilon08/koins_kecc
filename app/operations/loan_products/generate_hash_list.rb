module LoanProducts
  class GenerateHashList
    def initialize
      @loan_products  = LoanProduct.select("*").order("priority ASC")
      
      @data = {
        loan_products: []
      }
    end

    def execute!
      @loan_products.each do |o|
        @data[:loan_products] << o.to_h
      end

      @data
    end
  end
end
