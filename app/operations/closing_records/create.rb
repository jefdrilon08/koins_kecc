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
      @closing_date = closing_date
      @data_store   = data_store
      @user         = user

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

      @record
    end
  end
end
