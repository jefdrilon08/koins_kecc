module Members
  class Save
    def initialize(config:)
      super()

      @config       = config
      @member_data  = @config[:member_data]
      @user         = @config[:user]

      @member = Member.new
    end

    def execute!
      @member
    end
  end
end
