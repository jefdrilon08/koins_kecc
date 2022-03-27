module DataWarehouse
  class SaveDwBranchPureSaversMemberCount
    attr_accessor :branch,
                  :dw_branch_member_count

    def initialize(branch:, as_of:)
      @branch = branch
      @as_of  = as_of

      @cluster  = @branch.cluster
      @area     = @cluster.area

      @status = "pure_savers"

      @dw_branch_member_count = DwBranchMemberCount.find_by(
                                  branch_id:  @branch.id,
                                  as_of:      @as_of,
                                  status:     @status
                                )

      if @dw_branch_member_count.blank?
        @dw_branch_member_count = DwBranchMemberCount.new(
                                    branch:       @branch,
                                    cluster:      @cluster,
                                    area:         @area,
                                    as_of:        @as_of,
                                    status:       @status,
                                    count_male:   0,
                                    count_female: 0,
                                    total:        0
                                  )
      end
    end

    def execute!
      data  = ::Stats::ComputePureSavers.new(
                config: {
                  as_of: @as_of,
                  branch: @branch
                }
              ).execute!

      @dw_branch_member_count.count_male    = data[:male]
      @dw_branch_member_count.count_female  = data[:female]
      @dw_branch_member_count.total         = data[:male] + data[:female]

      @dw_branch_member_count.save!

      @dw_branch_member_count
    end
  end
end
