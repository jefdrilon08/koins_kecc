module Print
  class BuildMemberShare
    def initialize(member_share:)
      @member_share = member_share
      @member       = @member_share.member
      @data         = {}
    end

    def execute!
      @data[:member_full_name]  = "#{@member.first_name} #{@member.middle_name} #{@member.last_name}"
      @data[:date_of_issue_day]   = "#{@member_share.date_of_issue.day.ordinalize}"
      @data[:date_of_issue_month] = "#{@member_share.date_of_issue.month}"
      @data[:date_of_issue_year]  = "#{@member_share.date_of_issue.year}"

      @data
    end
  end
end
