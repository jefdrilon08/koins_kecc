module Loans
  class Apply
    def initialize(config:)
      @config       = config
      @loan_product = @config[:loan_product]
      @member       = @config[:member]
      @user         = @config[:user]
    end

    def execute!
      raise "not yet implemented"
    end
  end
end
