module Administration
  module UserBranches
    class Toggle
      def initialize(config:)
        super()

        @config       = config
        @user_branch  = @config[:user_branch]
        @current_user = @config[:current_user]
      end

      def execute!
        @user_branch.update!(
          active: @user_branch.active ? nil : true
        )

        @user_branch
      end
    end
  end
end
