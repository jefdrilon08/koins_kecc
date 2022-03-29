module DataWarehouse
  class SaveDwBranchMemberCountsFromDataStore
    attr_accessor :branch,
                  :as_of,
                  :data_store,
                  :data

    def initialize(data_store:)
      @data_store = data_store
      @data       = @data_store.data

      @branch   = ReadOnlyBranch.find(@data_store.meta["branch_id"])
      @cluster  = @branch.cluster
      @area     = @cluster.area
      @as_of    = @data_store.meta["as_of"].to_date
      @month    = @as_of.month
      @year     = @as_of.year
    end

    def execute!
      # pure_savers
      dw_branch_member_count = DwBranchMemberCount.find_by(
        as_of:        @as_of,
        branch_id:    @branch.id,
        record_type:  "pure_savers"
      )

      if dw_branch_member_count.blank?
        dw_branch_member_count = DwBranchMemberCount.new(
          as_of:        @as_of,
          month:        @month,
          year:         @year,
          branch:       @branch,
          cluster:      @cluster,
          area:         @area,
          record_type:  "pure_savers"
        )
      end

      dw_branch_member_count.count_male   = @data["counts"]["pure_savers"]["male"]
      dw_branch_member_count.count_female = @data["counts"]["pure_savers"]["female"]
      dw_branch_member_count.count_others = @data["counts"]["pure_savers"]["others"]
      dw_branch_member_count.total        = @data["counts"]["pure_savers"]["total"]

      dw_branch_member_count.save!

      # loaners
      dw_branch_member_count = DwBranchMemberCount.find_by(
        as_of:        @as_of,
        branch_id:    @branch.id,
        record_type:  "loaners"
      )

      if dw_branch_member_count.blank?
        dw_branch_member_count = DwBranchMemberCount.new(
          as_of:        @as_of,
          month:        @month,
          year:         @year,
          branch:       @branch,
          cluster:      @cluster,
          area:         @area,
          record_type:  "loaners"
        )
      end

      dw_branch_member_count.count_male   = @data["counts"]["loaners"]["male"]
      dw_branch_member_count.count_female = @data["counts"]["loaners"]["female"]
      dw_branch_member_count.count_others = @data["counts"]["loaners"]["others"]
      dw_branch_member_count.total        = @data["counts"]["loaners"]["total"]

      dw_branch_member_count.save!

      # active_members
      dw_branch_member_count = DwBranchMemberCount.find_by(
        as_of:        @as_of,
        branch_id:    @branch.id,
        record_type:  "active_members"
      )

      if dw_branch_member_count.blank?
        dw_branch_member_count = DwBranchMemberCount.new(
          as_of:        @as_of,
          month:        @month,
          year:         @year,
          branch:       @branch,
          cluster:      @cluster,
          area:         @area,
          record_type:  "active_members"
        )
      end

      dw_branch_member_count.count_male   = @data["counts"]["active_members"]["male"]
      dw_branch_member_count.count_female = @data["counts"]["active_members"]["female"]
      dw_branch_member_count.count_others = @data["counts"]["active_members"]["others"]
      dw_branch_member_count.total        = @data["counts"]["active_members"]["total"]

      dw_branch_member_count.save!

      # resigned
      dw_branch_member_count = DwBranchMemberCount.find_by(
        as_of:        @as_of,
        branch_id:    @branch.id,
        record_type:  "resigned"
      )

      if dw_branch_member_count.blank?
        dw_branch_member_count = DwBranchMemberCount.new(
          as_of:        @as_of,
          month:        @month,
          year:         @year,
          branch:       @branch,
          cluster:      @cluster,
          area:         @area,
          record_type:  "resigned"
        )
      end

      resigned_members  = Member.select(
                            "id, date_resigned, branch_id, gender"
                          ).where(
                            "EXTRACT(MONTH FROM date_resigned) = ? AND EXTRACT(YEAR FROM date_resigned) = ? AND branch_id = ?",
                            @month,
                            @year,
                            @branch.id
                          )

      dw_branch_member_count.count_male   = resigned_members.where("gender = ?", "Male").count("id")
      dw_branch_member_count.count_female = resigned_members.where("gender = ?", "Female").count("id")
      dw_branch_member_count.count_others = resigned_members.where("gender = ?", "Others").count("id")
      dw_branch_member_count.total        = resigned_members.count("id")

      dw_branch_member_count.save!
    end
  end
end
