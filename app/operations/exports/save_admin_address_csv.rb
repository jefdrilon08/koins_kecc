module Exports
  class SaveAdminAddressCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :admin_address

    def initialize(start_date:, end_date:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)
      
      if @start_date.blank? or @end_date.blank?
        raise "Invalid parameters"
      end

      @admin_address = AdminAddress.where("Date(updated_at) >= ? AND Date(updated_at) <= ? ", @start_date, @end_date)
    end

    def execute!
      cmd = Exports::GenerateAdminAddressCsv.new(
              admin_address: @admin_address
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "ADMIN_ADDRESS"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "admin_address.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end
  end
end
