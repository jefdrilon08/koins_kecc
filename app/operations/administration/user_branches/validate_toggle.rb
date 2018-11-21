module Administration
  module UserBranches
    class ValidateToggle < AppValidator
      def initialize(config:)
        super()

        @config       = config
        @user_branch  = @config[:user_branch]
        @current_user = @config[:current_user]
      end

      def execute!
        if @current_user.blank?
          @errors[:messages] << {
            key: "user",
            message: "user not found"
          }
        elsif !@current_user.is_mis?
          @errors[:messages] << {
            key: "user",
            message: "should be MIS user"
          }
        end

        if @user_branch.blank?
          @errors << {
            key: "user_branch",
            message: "user_branch not found"
          }
        end

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
    end
  end
end
