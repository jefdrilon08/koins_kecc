module DataWarehouse
  class SaveDwBranchMonthlyLoanProductDisbursedCount
    attr_accessor :branch,
                  :as_of,
                  :loan_product,
                  :result,
                  :record

    def initialize(branch:, as_of:, loan_product:)
      @branch                 = branch
      @as_of                  = as_of.to_date
      @loan_product           = loan_product
      @loan_product_category  = loan_product.loan_product_category

      @cluster  = @branch.cluster
      @area     = @cluster.area

      @month    = @as_of.month
      @year     = @as_of.year
    end

    def execute!
      @record = DwBranchMonthlyLoanProductDisbursedCount.find_by(
        branch_id:        @branch.id,
        loan_product_id:  @loan_product.id,
        month:            @month,
        year:             @year
      )

      if @record.blank?
        @record = DwBranchMonthlyLoanProductDisbursedCount.new(
          branch:                 @branch,
          area:                   @area,
          cluster:                @cluster,
          loan_product:           @loan_product,
          loan_product_category:  @loan_product_category,
          month:                  @month,
          year:                   @year
        )
      end

      @result = ReadOnlyLoan.active_or_paid.where(
        branch_id: @branch.id,
        loan_product_id: @loan_product.id
      ).where(
        "EXTRACT(month FROM date_released) = ? AND EXTRACT(year FROM date_released) = ?",
        @month,
        @year
      ).select(
        "COUNT(loans.loan_product_id) AS total, SUM(loans.principal) AS amount_released, loans.loan_product_id"
      ).group(
        "loans.loan_product_id"
      )

      if @result.any?
        @record.total   = @result[0].total
        @record.amount  = @result[0].amount_released
      else
        @record.total   = 0
        @record.amount  = 0
      end

      # data
      @record.data = {
      }

      @record.status = "done"
      @record.save!

      @record
    end
  end
end
