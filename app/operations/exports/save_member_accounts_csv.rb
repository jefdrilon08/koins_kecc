module Exports
  class SaveMemberAccountsCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :member_accounts

    def initialize(start_date:, end_date:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)

      if @start_date.blank? or @end_date.blank?
        raise "Invalid parameters"
      end

      @member_accounts = MemberAccount.insurance.where("Date(member_accounts.updated_at) >= ? AND Date(member_accounts.updated_at) <= ?", @start_date, @end_date)
    end

    def execute!
      cmd = Exports::GenerateMemberAccountsCsv.new(
              member_accounts: @member_accounts
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "MEMBER_ACCOUNTS"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "member_accounts.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end
  end
end
