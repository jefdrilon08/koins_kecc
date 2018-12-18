module MonthlyClosingCollections
  class Create
    def initialize(config:)
      @config = config

      @closing_date = @config[:closing_date]
    end

    def execute!
    end
  end
end
