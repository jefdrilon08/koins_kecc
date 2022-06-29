module ClosingRecords
  class Create
    attr_accessor :data,
                  :branch,
                  :record_type,
                  :closing_date

    def initialize(branch:, record_type:, closing_date:)
      @branch       = branch
      @record_type  = record_type
      @closing_date = closing_date

      @data = {
      }
    end

    def execute!
    end
  end
end
