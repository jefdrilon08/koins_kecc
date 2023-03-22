module PsrSchedules
  class ValidateGenerate
    attr_accessor :errors

    def initialize(branch_ids:, year:, month:)
      @branch_ids = branch_ids
      @year       = year
      @month      = month
      @errors     = []
    end

    def execute!
      if @branch_ids.blank?
        @errors << "no branch_ids found"
      end

      if @month.blank?
        @errors << "month required"
      end

      if @year.blank?
        @errors << "year required"
      end

      if @branch_ids.present? and @month.present? and @year.present?
        @branch_ids.each do |branch_id|
          branch_psr_record = BranchPsrRecord.done.where(
            branch_id:      branch_id,
            closing_month:  @month,
            closing_year:   @year
          ).first

          if branch_psr_record.blank?
            branch = Branch.find(branch_id)
            @errors << "no PSR record found for branch #{branch.try(:name)}"
          end
        end
      end

      @errors
    end

    def valid?
      @errors.blank?
    end
  end
end
