module Imports
  class ImportBeneficiaries
    attr_accessor :actual_url

    def initialize(actual_url:)
      @actual_url = actual_url
    end

    def execute!
      @file       = URI.open(@actual_url)

      ::Members::ImportBeneficiariesFromCsvFile.new(
        file: @file
      ).execute!
    end
  end
end
