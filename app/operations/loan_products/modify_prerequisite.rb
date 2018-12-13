module LoanProducts
  class ModifyPrerequisite
    def initialize(config:)
      @config = config

      @loan_product = @config[:loan_product]
      @prerequisite = @config[:prerequisite]
    end

    def execute!
      data  = @loan_product.data

      if data.blank?
        data  = {}
      else
        data  = data.with_indifferent_access
      end

      data[:prerequisite_id]  = @prerequisite.try(:id)

      @loan_product.update!(
        data: data
      )
    end
  end
end
