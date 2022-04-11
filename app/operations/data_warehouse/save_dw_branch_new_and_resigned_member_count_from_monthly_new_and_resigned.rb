module DataWarehouse
  class SaveDwBranchNewAndResignedMemberCountFromMonthlyNewAndResigned
    attr_accessor :branch,
                  :year,
                  :month,
                  :data

    def initialize(branch:, year:, month:, data:)
      @branch = branch
      @year   = year
      @month  = month
      @data   = data

      @cluster  = @branch.cluster
      @area     = @cluster.area
    end

    def execute!
      dw_branch_new_member_count = DwBranchNewMemberCount.find_by(
        year:       @year,
        month:      @month,
        branch_id:  @branch.id
      )

      if dw_branch_new_member_count.blank?
        dw_branch_new_member_count = DwBranchNewMemberCount.new(
          year:         @year,
          month:        @month,
          branch:       @branch,
          cluster:      @cluster,
          area:         @area,
          total:        0
        )
      end

      dw_branch_new_member_count.total = @data[:num_new]

      dw_branch_new_member_count.save!

      dw_branch_resigned_member_count = DwBranchResignedMemberCount.find_by(
        year:       @year,
        month:      @month,
        branch_id:  @branch.id
      )

      if dw_branch_resigned_member_count.blank?
        dw_branch_resigned_member_count = DwBranchResignedMemberCount.new(
          year:         @year,
          month:        @month,
          branch:       @branch,
          cluster:      @cluster,
          area:         @area,
          total:        0
        )
      end

      dw_branch_resigned_member_count.total = @data[:num_resigned]

      dw_branch_resigned_member_count.save!
    end
  end
end
