module Print
  class BuildPrintKbenteBill
    def initialize(config:)

      @config             = config
      @print_kbente_bill  = @config[:print_kbente_bill]
      @data = @print_kbente_bill[:data].with_indifferent_access
      # @response = JSON.parse(HTTParty.get(@data["records"]).body)
    end
    def execute!
      @data
      @print_kbente_bill
    end
  end
end
