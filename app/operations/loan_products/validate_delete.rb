module LoanProducts
  class ValidateDelete < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @loan_product = @config[:loan_product]
      @user         = @config[:user]
    end

    def execute!
      if Loan.where(loan_product_id: @loan_product.id).count > 0
        @errors[:messages] << {
          key: "loan_product",
          message: "This loan product still has loans"
        }
      end

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
