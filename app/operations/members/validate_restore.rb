module Members
  class ValidateRestore < AppValidator
    def initialize(config:)
      super()

      @config = config
      @member = @config[:member]
      @user   = @config[:user]

      @valid_roles  = ["MIS", "SBK"]
    end

    def execute!
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member not found"
        }
      end

      if @member.present? && !@member.resigned?
        @errors[:messages] << {
          key: "member",
          message: "Cannot restore member. Status is not resigned."
        }
      end

      if @user.present?
        if (@valid_roles & @user.roles).size == 0
          @errors[:messages] << {
            key: "user",
            message: "Unauthorized role/s: #{@user.roles}"
          }
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
