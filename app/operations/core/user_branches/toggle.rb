module Core
  module UserBranches
    class Toggle
      attr_accessor :user_branch

      def initialize(branch_id:, user_id:)
        @branch_id  = branch_id
        @user_id    = user_id
      end

      def execute!
        @user_branch = UserBranch.where(
          user_id:    @user_id,
          branch_id:  @branch_id
        ).first

        if @user_branch.blank?
          @user_branch = UserBranch.create(
            user:   User.find(@user_id),
            branch: Branch.find(@branch_id),
            active: true
          )
        else
          @user_branch.update!(
            active: @user_branch.active ? true : nil
          )
        end

        @user_branch
      end
    end
  end
end
