module Exports
  class SaveMembersCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :members

    def initialize(start_date:, end_date:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)

      if @start_date.blank? or @end_date.blank?
        raise "Invalid parameters"
      end

      @members = Member.where("Date(members.updated_at) >= ? AND Date(members.updated_at) <= ?", @start_date, @end_date)
    end

    def execute!
      cmd = Exports::GenerateMembersCsv.new(
              members: @members
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "MEMBERS"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "members.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end
  end
end
