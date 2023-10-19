module LoanProducts
  class BuildClientList
    attr_reader :data

    def initialize
      @data = {
        loan_product_categories: []
      }
    end

    def execute!
      @loan_product_categories = LoanProductCategory.order(
        "name ASC"
      ).map{ |o|
        o.to_h
      }

      @loan_product_categories.each do |loan_product_category|
        loan_product_category[:loan_products] = LoanProduct.where(
          loan_product_category_id: loan_product_category[:id]
        ).order(
          "name ASC"
        ).map{ |o|
          o.to_h
        }
      end

      @data[:loan_product_categories] = @loan_product_categories
    end
  end
end
