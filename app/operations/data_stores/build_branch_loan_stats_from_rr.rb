module DataStores
  class BuildBranchLoanStatsFromRr
    def initialize(rr_data:)
      @rr_data  = rr_data

      @data = {
        loan_products: [],
        branch: @rr_data[:branch],
        as_of: @rr_data[:as_of],
        total_active_loans: 0,
        total_principal: 0.00,
        total_principal_paid: 0.00,
        total_portfolio: 0.00,
        total_past_due_amount: 0.00,
        total_par_amount: 0.00,
        total_par_rate: 0,
        total_rr: 0
      }

      # Loan Products
      @loan_products  = LoanProduct.all.order("priority_asc")

      @loan_products.each do |o|
        @data[:loan_products] << {
          id: o.id,
          name: o.name,
          active_loans: 0,
          principal: 0.00,
          principal_paid: 0.00,
          portfolio: 0.00,
          past_due_amount: 0.00,
          par_amount: 0.00,
          par_rate: 0,
          rr: 0,
          records: []
        }
      end
    end

    def execute!
      @rr_data[:records].each do |o|
      end

      @data
    end
  end
end
