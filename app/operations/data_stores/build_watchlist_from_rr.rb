module DataStores
  class BuildWatchlistFromRr
    def initialize(rr_data:)
      @rr_data  = rr_data

      @data = {
        loan_products: [],
        records: [],
        as_of: @rr_data[:as_of]
      }
    end

    def execute!
      loan_product_ids  = []

      @rr_data[:records].each do |o|
        if o[:total_balance].to_f > 0
          @data[:records] << o
          loan_product_ids << o[:loan_product][:id]
        end
      end

      @data[:loan_products] = LoanProduct.where(id: loan_product_ids.uniq)

      @data
    end
  end
end
