module Members
  class ValidateDelete  < AppValidator
    def initialize(config:)
      super()

      @config = config
      @member = @config[:member]
      @user   = @config[:user]

      @valid_roles  = ["MIS", "BK", "SBK", "REMOTE-BK", "REMOTE-FM"]
    end

    def execute!
      if !@member.pending?
        @errors[:messages] << {
          key: "status",
          message: "member not pending"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User not found"
        }
      elsif (@valid_roles & @user.roles).size == 0
        @errors[:messages] << {
          key: "user",
          message: "unauthorized roles: #{@user.roles}"
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
