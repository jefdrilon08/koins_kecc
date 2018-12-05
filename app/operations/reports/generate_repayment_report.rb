module Reports
  class GenerateRepaymentReport
    def initialize(config:)
      @config = config

      @as_of          = @config[:as_of]
      @branch         = @config[:branch]
      @loan_products  = LoanProduct.all
      @centers        = @branch.centers.order("name ASC")
      @so_officers    = User.where(id: @centers.pluck(:user_id))
      @loans          = Loan.where(
                          "status = ? OR date_completed > ?",
                          'active',
                          @as_of
                        )

      @data = {
        loan_products: []
      }
    end

    def execute!
      @loan_products
      @data
    end
  end
end
