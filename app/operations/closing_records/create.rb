module ClosingRecords
  class Create
    attr_accessor :data,
                  :branch,
                  :record_type,
                  :closing_date,
                  :data_store

    def initialize(branch:, record_type:, closing_date:, data_store:)
      @branch       = branch
      @record_type  = record_type
      @closing_date = closing_date
      @data_store   = data_store

      @data = {
      }
    end

    def execute!
    end
  end
end
