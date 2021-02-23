module MonthlyAccountingCodeSummaries
  class ValidateCreate < AppValidator
    attr_accessor :errors

    def initialize(config:)
      super()

      @config = config

      @branch_id  = @config[:branch_id]
      @year       = @config[:year]
      @month      = @config[:month]
      @branch     = Branch.find_by_id(@branch_id)
    end

    def execute!
      if @branch_id.blank?
        @errors[:messages] << {
          key: "branch_id",
          message: "branch_id required"
        }
      end

      if @year.blank?
        @errors[:messages] << {
          key: "year",
          message: "year required"
        }
      end

      if @month.blank?
        @errors[:messages] << {
          key: "month",
          message: "month required"
        }
      end

      if @branch.present? and @year.present? and @month.present?
        if MonthlyAccountingCodeSummary.where(branch_id: @branch_id, year: @year, month: @month).count > 0
          @errors[:messages] << {
            key: "monthly_accounting_code_summary",
            message: "Records exist for month #{@month} and year #{@year} for branch #{@branch.name}"
          }
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
