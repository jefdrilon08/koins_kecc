module Closing
  class ValidateYearEndGenerate < AppValidator
    def initialize(config:)
      super()
  
      @config       = config
      @branch       = @config[:branch]
      @closing_date = @config[:closing_date].try(:to_date)
    end

    def execute!
      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Branch not found"
        }
      end

      if @closing_date.blank?
        @errors[:messages] << {
          key: "closing_date",
          message: "Closing date not found"
        }
      end

      if @branch.present? and @closing_date.present?
        year  = @closing_date.year

        if DataStore.year_end_closings.where("CAST(meta->>'year' AS integer) = ? AND meta->>'branch_id' = ?", year, @branch.id).count > 0
          @errors[:messages] << {
            key: "closing_date",
            message: "Already has closing record for year #{@year}"
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
