module ClosingRecords
  class Create
    attr_accessor :data,
                  :branch,
                  :record_type,
                  :closing_date,
                  :data_store,
                  :record

    def initialize(branch:, record_type:, closing_date:, data_store:, user:)
      @branch       = branch
      @record_type  = record_type
      @closing_date = closing_date.to_date
      @data_store   = data_store
      @user         = user

      @month  = @closing_date.month
      @year   = @closing_date.year

      @data = {}
    end

    def execute!
      @data[:closed_by] = {
        id:         @user.id,
        username:   @user.username,
        first_name: @user.first_name,
        last_name:  @user.last_name
      }

      @record = AdministrationBranchClosingRecord.new(
        branch:       @branch,
        record_type:  @record_type,
        closing_date: @closing_date,
        data_store:   @data_store,
        data:         @data
      )

      @record.save!

      # Trigger nullifying current_date in branch
      closing_records = ReadOnlyAdministrationBranchClosingRecord.where(
        "branch_id = ? AND EXTRACT(month FROM closing_date) = ? AND EXTRACT(year FROM closing_date) = ?",
        @branch.id,
        @month,
        @year
      )

      if closing_records.count == ReadOnlyAdministrationBranchClosingRecord::RECORD_TYPES.size
        b = Branch.find(@branch.id)
        b.update!(current_date: nil)
      end

      @record
    end
  end
end
