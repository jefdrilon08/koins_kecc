module LoanProducts
  attr_accessor :loan_products

  class FetchList
    def initialize()
      @loan_products = LoanProduct.select("*").order("priority ASC, name ASC")
    end

    def execute!
      result = @loan_products.map{ |o|
        {
          id: o.id,
          name: o.name
        }
      }

      result
    end
  end
end
