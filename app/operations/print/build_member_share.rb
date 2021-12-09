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
      @data[:number_of_shares]    = "#{@member_share.number_of_shares}"
      @data[:shares_in_words]     = "#{in_words(@member_share.number_of_shares)}"
      @data
    end

    def in_words(int)
      numbers_to_name = {
        90 => "siyamnapu",
        80 => "walumpu",
        70 => "pitumpu",
        60 => "animnapu",
        50 => "limangpu",
        40 => "apatnapu",
        30 => "tatlumpu",
        20 => "dalawampu",
        19=>"labing siyam",
        18=>"labing walo",
        17=>"labing pito",
        16=>"labing anim",
        15=>"labing lima",
        14=>"labing apat",
        13=>"labing tatlo",
        12=>"labing dalawa",
        11 => "labing isa",
        10 => "sampu",
        9 => "siyam",
        8 => "walo",
        7 => "pito",
        6 => "anim",
        5 => "lima",
        4 => "apat",
        3 => "tatlo",
        2 => "dalawa",
        1 => "isa"
      }
    str = ""
    numbers_to_name.each do |num, name|
      if int == 0
        return str
      elsif int.to_s.length == 1 && int/num > 0
        return str + "#{name}"
      elsif int < 100 && int/num > 0
        return str + "#{name}" if int%num == 0
        return str + "#{name}"+"t " + in_words(int%num)
      elsif int/num > 0
        return str + in_words(int/num) + " #{name} " + in_words(int%num)
      end
    end
  end

  end
end
