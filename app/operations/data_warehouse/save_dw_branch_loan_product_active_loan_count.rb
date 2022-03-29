module DataWarehouse
  class SaveDwBranchLoanProductActiveLoanCount
    attr_accessor :branch,
                  :as_of,
                  :loan_product,
                  :loan_product_category

    def initialize(branch:, as_of:, loan_product:)
      @loan_product           = loan_product
      @loan_product_category  = @loan_product.loan_product_category
      @branch                 = branch
      @as_of                  = as_of.to_date
      @month                  = @as_of.month
      @year                   = @as_of.year

      @cluster  = @branch.cluster
      @area     = @cluster.area
      @total    = 0
    end

    def execute!
      @dw_branch_loan_product_active_loan_count = DwBranchLoanProductActiveLoanCount.where(
        loan_product_id:          @loan_product.id,
        loan_product_category_id: @loan_product_category.id,
        branch_id:                @branch.id,
        cluster_id:               @cluster.id,
        area_id:                  @area.id,
        month:                    @month,
        year:                     @year
      ).first

      if @dw_branch_loan_product_active_loan_count.blank?
        @dw_branch_loan_product_active_loan_count = DwBranchLoanProductActiveLoanCount.new(
          loan_product:           @loan_product,
          loan_product_category:  @loan_product_category,
          branch:                 @branch,
          as_of:                  @as_of,
          cluster:                @cluster,
          area:                   @area,
          total:                  @total,
          month:                  @month,
          year:                   @year
        )
      end

      # Load date metrics
      @dw_branch_loan_product_active_loan_count.as_of  = @as_of
      @dw_branch_loan_product_active_loan_count.month  = @month
      @dw_branch_loan_product_active_loan_count.year   = @year

      @total  = Loan.select("id, loan_product_id, branch_id, status, max_active_date").where(
                  "loan_product_id = ? AND branch_id = ? AND status IN (?) AND DATE(max_active_date) <= ?",
                  @loan_product.id,
                  @branch.id,
                  [
                    "active",
                    "paid"
                  ],
                  @as_of
                ).count("id")

      @dw_branch_loan_product_active_loan_count.total = @total

      @dw_branch_loan_product_active_loan_count.save!

      @dw_branch_loan_product_active_loan_count
    end
  end
end
