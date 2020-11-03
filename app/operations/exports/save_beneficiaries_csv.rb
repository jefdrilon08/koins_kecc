module Exports
  class SaveBeneficiariesCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :beneficiaries

    def initialize(start_date:, end_date:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)

      if @start_date.blank? or @end_date.blank?
        raise "Invalid parameters"
      end

      @beneficiaries = Beneficiary.where("Date(beneficiaries.updated_at) >= ? AND Date(beneficiaries.updated_at) <= ?", @start_date, @end_date)
    end

    def execute!
      cmd = Exports::GenerateBeneficiariesCsv.new(
              beneficiaries: @beneficiaries
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "BENEFICIARIES"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "beneficiaries.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end
  end
end
