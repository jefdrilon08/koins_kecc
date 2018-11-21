module Administration
  module UserBranches
    class Fetch
      def initialize(config:)
        @config       = config
        @user         = @config[:user]
        @current_user = @config[:current_user]

        puts @config

        @branches = Branch.all.order("name ASC")

        @user_branches  = []
      end

      def execute!
        @branches.each do |branch|
          user_branch = UserBranch.where(branch_id: branch.id, user_id: @user.id).first

          if user_branch.blank?
            user_branch = UserBranch.new(
                            user_id: @user.id,
                            branch_id: branch.id
                          )

            user_branch.save!
          end

          @user_branches << {
            id: user_branch.id,
            active: user_branch.active ?  true : false,
            branch: {
              id: user_branch.branch.id,
              name: user_branch.branch.name
            }
          }
        end

        @user_branches
      end
    end
  end
end
