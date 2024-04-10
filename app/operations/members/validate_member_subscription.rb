
module Members
    class ValidateMemberSubscription  < AppValidator
      def initialize(config:)
        super()

        @config = config
        @member = @config[:member]
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

        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
    end
end