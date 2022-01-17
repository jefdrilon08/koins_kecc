module Exports
  class SaveCentersCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :centers, :branch

    def initialize(start_date:, end_date:, branch:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)
      @branch     = branch

      if @start_date.blank? or @end_date.blank? or @branch.blank?
        raise "Invalid parameters"
      end

      @centers = Center.where("Date(centers.updated_at) >= ? AND Date(centers.updated_at) <= ? AND branch_id = ?", @start_date, @end_date, @branch.id)
    end

    def execute!
      cmd = Exports::GenerateCentersCsv.new(
              centers: @centers
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "CENTERS"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "centers.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end
  end
end
