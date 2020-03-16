module DataStores
  class BuildWatchlistFromRr
    def initialize(records:, as_of:)
      @records = records
      @as_of = as_of
    end

    def execute!
      records = @records.select { |r| r["total_balance"].to_f > 0 }

      center_ids = records
        .map { |r| r["center"]["id"] }
        .uniq
      centers = Center
        .where(id: center_ids)
        .order("name ASC")
        .map { |c| { id: c.id, name: c.name } }

      loan_product_ids = records
        .map { |r| r["loan_product"]["id"] }
        .uniq
      loan_products = LoanProduct
        .where(id: loan_product_ids)
        .map { |l| { id: l.id, name: l.name } }

      {
        as_of: @as_of,
        centers: centers,
        loan_products: loan_products,
        records: records,
      }
    end
  end
end
