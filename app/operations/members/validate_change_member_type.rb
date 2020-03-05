module Members
  class ValidateChangeMemberType < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @member       = @config[:member]
      @user         = @config[:user]
      @member_type  = @config[:member_type]
    
      @valid_roles = ["MIS", "BK", "SBK", "REMOTE-BK", "REMOTE-FM", "OAS", "AO"]
    end

    def execute!  
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "member not found"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      end

      if @member_type.blank?
        @errors[:messages] << {
          key: "member_type",
          message: "No member type found"
        }
      end

      if @member.present? and @member_type.present? and @member.member_type == @member_type
        @errors[:messages] << {
          key: "member_type",
          message: "Same member type"
        }
      end

      if @member_type.present? and Settings.default_member_types.present?
        if !Settings.default_member_types.include?(@member_type)
          @errors[:messages] << {
            key: "member_type",
            message: "Invalid member type #{@member_type}"
          }
        end
      end

      if (@user.roles & @valid_roles).size == 0
        @errors[:messages] << {
          key: "auth",
          message: "invalid role #{@user.roles}"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
