module LoanProducts
  class ModifyMaintainingBalance < AppValidator
    def initialize(config:)
      @config = config

      @loan_product         = @config[:loan_product]
      @maintaining_balance  = @config[:maintaining_balance].try(:to_f)
    end

    def execute!
      data  = @loan_product.data

      if data.blank?
        data  = {}
      else
        data  = data.with_indifferent_access
      end

      data[:maintaining_balance]  = @maintaining_balance

      @loan_product.update!(
        data: data
      )
    end
  end
end
