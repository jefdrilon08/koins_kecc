module Imports
  class ImportAdminAddress
    attr_accessor :actual_url

    def initialize(actual_url:)
      @actual_url = actual_url
      @current_user = User.where("first_name = ? AND last_name = ?","kaiser", "velilia").first
    end

    def execute!
      @temp_file       = URI.open(@actual_url)

      if @temp_file.is_a?(StringIO)
        @file = Tempfile.new
        File.write(@file.path, @temp_file.string)
      else
        @file = @temp_file
      end

      ::Administration::AdministrationAddress::ImportAdminAddressFromCsvFile.new(
        file: @file,
        user: @current_user
      ).execute!
    end
  end
end
