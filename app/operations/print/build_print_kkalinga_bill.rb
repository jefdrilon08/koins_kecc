module Print
  class BuildPrintKkalingaBill
    def initialize(config:)

      @config             = config
      @print_kkalinga_bill  = @config[:print_kkalinga_bill]
      @data = @print_kkalinga_bill[:data].with_indifferent_access
    end
    def execute!
      @data
      @print_kkalinga_bill
    end
  end
end