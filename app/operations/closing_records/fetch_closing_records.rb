module ClosingRecords
  class FetchClosingRecords
    attr_accessor :records,
                  :branch,
                  :closing_date

    def initialize(branch:, closing_date:)
      @branch       = branch
      @closing_date = closing_date.to_date

      @month  = @closing_date.month
      @year   = @closing_date.year

      @records = []
    end

    def execute!
      results = AdministrationBranchClosingRecord.where(
        "branch_id = ? AND EXTRACT(month FROM closing_date) = ? AND EXTRACT(year FROM closing_date) = ?",
        @branch.id,
        @month,
        @year
      )

      results.each do |o|
        @records << {
          type:         o.record_type,
          closing_date: o.closing_date.strftime("%b %d %Y"),
          status:       "done"
        }
      end

      current_record_types = results.pluck(:record_type)

      ReadOnlyAdministrationBranchClosingRecord::RECORD_TYPES.each do |record_type|
        if !current_record_types.include?(record_type)
          @records << {
            type:         record_type,
            closing_date: "N/A",
            status:       "pending"
          }
        end
      end

      @records
    end
  end
end
