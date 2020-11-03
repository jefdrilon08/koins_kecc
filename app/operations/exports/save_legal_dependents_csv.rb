module Exports
  class SaveLegalDependentsCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :legal_dependents

    def initialize(start_date:, end_date:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)

      if @start_date.blank? or @end_date.blank?
        raise "Invalid parameters"
      end

      @legal_dependents = LegalDependent.where("Date(legal_dependents.updated_at) >= ? AND Date(legal_dependents.updated_at) <= ?", @start_date, @end_date)
    end

    def execute!
      cmd = Exports::GenerateLegalDependentsCsv.new(
              legal_dependents: @legal_dependents
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "LEGAL_DEPENDENTS"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "legal_dependents.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end
  end
end
