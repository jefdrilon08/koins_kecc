module Members
  class ValidateUploadProfilePicture < AppValidator
    def initialize(config:)
      super()

      @config = config
      @files  = @config[:files]
      @user   = @config[:user]
      @member = @config[:member]

      @valid_roles = ["MIS", "BK", "SBK", "REMOTE-BK", "REMOTE-FM"]
    end

    def execute!
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "member required"
        }
      end

      if (@user.roles & @valid_roles).size == 0
        @errors[:messages] << {
          key: "auth",
          message: "invalid role #{@user.roles}"
        }
      end

      #not_yet_implemented!
      
      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
