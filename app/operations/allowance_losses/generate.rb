module AllowanceLosses
  class Generate
    attr_accessor :data

    def initialize(date_select:)
      @date_select = date_select
      @data = []
    end

    def execute!
      @data = DataStore.where(status: 'done')
                       .where("meta ->> 'as_of' IN (?) AND meta ->> 'data_store_type' = ?", @date_select, "ALLOWANCE_COMPUTATION")

      @data
    end
  end
end
