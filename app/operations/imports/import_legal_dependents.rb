module Imports
  class ImportLegalDependents
    attr_accessor :actual_url

    def initialize(actual_url:)
      @actual_url = actual_url
    end

    def execute!
      @temp_file       = URI.open(@actual_url)

      if @temp_file.is_a?(StringIO)
        @file = Tempfile.new
        File.write(@file.path, @temp_file.string)
      else
        @file = @temp_file
      end

      ::Members::ImportLegalDependentsFromCsvFile.new(
        file: @file
      ).execute!
    end
  end
end
