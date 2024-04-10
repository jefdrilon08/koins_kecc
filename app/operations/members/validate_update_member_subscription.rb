module Members
    class ValidateUpdateMemberSubscription  < AppValidator
      def initialize(config:)
        super()

        @config = config
        @member = @config[:member]
        @member_data = @member.data
        @user   = @config[:user]
        @valid_roles  = ["MIS", "BK"]

        # @valid_roles = ::Users::FetchValidRoles.new(
        #   module_name: "unlock_member_modification"
        # ).execute!
      end

      def execute!
        if @member.nil?
            @errors[:messages] << {
                key: "member",
                message: "Member not found."
            }
        end 

        if (@user.roles & @valid_roles).size == 0
          @errors[:messages] << {
            key: "auth",
            message: "invalid role #{@user.roles}"
          }

        end

        if !@member_data.key?("subscription")
            @errors[:messages] << {
                key: "subscription",
                message: "subscription not found."
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
