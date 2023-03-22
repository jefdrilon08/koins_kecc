module PsrSchedules
  class Generate
    attr_accessor :data

    def initialize(branch_ids:, year:, month:)
      @branch_ids = branch_ids
      @branches   = Branch.where(branch_ids: branch_ids)
      @year       = year
      @month      = month
    end

    def execute!
      @data = BranchPsrRecord.done.where(
        branch_id:      @branch_ids,
        closing_month:  @month,
        closing_year:   @year
      ).map{ |o| o.to_h }.uniq{ |o| o[:branch_id] }

      @data
    end
  end
end
