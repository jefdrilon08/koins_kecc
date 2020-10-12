module Imports
  class ImportMembers
    attr_accessor :actual_url

    def initialize(actual_url:)
      @actual_url = actual_url
      @current_user = User.where("first_name = ? AND last_name = ?","Aljon", "Laureano").first
    end

    def execute!
      @file       = URI.open(@actual_url)

      ::Members::ImportMembersFromCsvFile.new(
        file: @file,
        user: @current_user
      ).execute!
    end
  end
end
