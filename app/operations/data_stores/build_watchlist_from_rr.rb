module DataStores
  class BuildWatchlistFromRr
    def initialize(rr_data:)
      @rr_data  = rr_data

      @data = {
        loan_products: [],
        centers: [],
        records: [],
        as_of: @rr_data[:as_of]
      }
    end

    def execute!
      loan_product_ids  = []
      center_ids        = []

      @rr_data[:records].each do |o|
        if o[:total_balance].to_f > 0
          @data[:records] << o
          loan_product_ids << o[:loan_product][:id]
          center_ids << o[:center][:id]
        end
      end

      @data[:centers] = Center.where(id: center_ids).order("name ASC").map{ |o|
                          {
                            id: o.id,
                            name: o.name
                          }
                        }


      @data[:loan_products] = LoanProduct.where(id: loan_product_ids.uniq).map{ |o|
                                {
                                  id: o.id,
                                  name: o.name
                                }
                              }

      @data
    end
  end
end
