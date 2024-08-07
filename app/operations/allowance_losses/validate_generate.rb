module AllowanceLosses
  class ValidateGenerate
    attr_accessor :errors

    def initialize(date_select:)
      @date_select = date_select
      @errors = []
    end

    def execute!
      if @date_select.blank?
        @errors << "Date selection is required."
        return @errors
      end

      @date_select.each do |date|
        allowance_record = DataStore.where("meta ->> ? = ? AND meta ->> ? = ?", "data_store_type", "ALLOWANCE_COMPUTATION", "as_of", date).first

        if allowance_record.blank?
          @errors << "No Allowance Computation Record found for date #{date}."
        end
      end

      @errors
    end

    def valid?
      @errors.blank?
    end
  end
end
