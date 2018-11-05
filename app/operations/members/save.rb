module Members
  class Save
    def initialize(config:)
      super()

      @config       = config
      @member_data  = @config[:member_data]
      @user         = @config[:user]

      @branch = Branch.find(@member_data[:branch_id])
      @center = Center.find(@member_data[:center_id])

      @member = Member.new

      if @member_data[:id].present?
        @member = Member.find(@member_data[:id])
      end
    end

    def execute!
      @member.first_name      = @member_data[:first_name]
      @member.middle_name     = @member_data[:middle_name]
      @member.last_name       = @member_data[:last_name]
      @member.gender          = @member_data[:gender]
      @member.date_of_birth   = @member_data[:date_of_birth]
      @member.civil_status    = @member_data[:civil_status]
      @member.home_number     = @member_data[:home_number]
      @member.mobile_number   = @member_data[:mobile_number]
      @member.place_of_birth  = @member_data[:place_of_birth]
      @member.member_type     = @member_data[:member_type]
      @member.religion        = @member_data[:religion]
      @member.data            = @member_data[:data]

      @member.branch  = @branch
      @member.center  = @center

      @member.save!

      @member
    end
  end
end
