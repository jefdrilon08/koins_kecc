module Imports
  class ImportLegalDependents
    attr_accessor :actual_url

    def initialize(actual_url:)
      @actual_url = actual_url
    end

    def execute!
      @file       = URI.open(@actual_url)

      ::Members::ImportLegalDependentsFromCsvFile.new(
        file: @file
      ).execute!
    end
  end
end
