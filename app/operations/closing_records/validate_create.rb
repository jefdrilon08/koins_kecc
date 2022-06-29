module ClosingRecords
  class ValidateCreate
    attr_accessor :errors,
                  :branch,
                  :record_type,
                  :closing_date,
                  :data_store,
                  :user

    def initialize(branch:, record_type:, closing_date:, data_store:, user:)
      @branch       = branch
      @record_type  = record_type
      @closing_date = closing_date.try(:to_date)
      @data_store   = data_store
      @user         = user

      @errors = []
    end

    def execute!
      if @branch.blank?
        @errors << "Branch required"
      end

      if @record_type.blank?
        @errors << "Record type required"
      end

      if @closing_date.blank?
        @errors << "Closing date required"
      else
        current_date = Date.today

        if @branch.current_date.present?
          current_date = @branch.current_date
        end

        if @closing_date.year != current_date.year
          @errors << "Invalid year"
        end

        if @closing_date.month != current_date.month
          @errors << "Invalid month"
        end
      end

      if @data_store.blank?
        @errors << "Data store required"
      end

      if @branch.present? and @record_type.present? and @closing_date.present? and @data_store.present?
        record = ReadOnlyAdministrationBranchClosingRecord.where(
          branch_id:      @branch.id,
          record_type:    @record_type,
          data_store_id:  @data_store.id
        ).where(
          "EXTRACT(month FROM closing_date) = ? AND EXTRACT(year FROM closing_date) = ?",
          @closing_date.month,
          @closing_date.year
        ).first

        if record.present?
          @errors << "Record already registered" 
        end
      end

      @errors
    end
  end
end
