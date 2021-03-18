module Print
  class BuildMemberShareForMba
    def initialize(member_share:)
      @member_share = member_share
      @member       = @member_share.member
      @data         = {}
    end

    def execute!
      @data[:identification_number] = "#{@member.identification_number}"
      @data[:member_full_name]      = "#{@member.full_name_middle_initial}"
      @data[:branch]                = "#{@member.branch.name.try(:upcase)}"
      @data[:center]                = "#{@member.center.name.try(:upcase)}"
      @data[:day]                   = "#{@member_share.date_of_issue.day.ordinalize}"
      @data[:month]                 = "#{@member_share.date_of_issue.strftime("%B")}"
      @data[:year]                  = "#{@member_share.date_of_issue.strftime("%y")}"
      @data[:number_of_shares]      = "#{@member_share.number_of_shares}"
      
      @data
    end
  end
end
