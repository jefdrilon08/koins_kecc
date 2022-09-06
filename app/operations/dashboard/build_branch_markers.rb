module Dashboard
  class BuildBranchMarkers
    attr_accessor :data

    def initialize(user:)
      @user = user

      @branches = ReadOnlyBranch.where(
        id: ReadOnlyUserBranch.where(
          active: true, 
          user_id: @user.id
        ).pluck(:branch_id)
      ).order("name ASC")

      @data = []
    end

    def execute!
      @data = @branches.map{ |branch|
        obj = branch.to_obj

        obj
      }

      @data
    end
  end
end
