module MonthlyIncentives
  class ValidateQueue < AppValidator
    attr_reader :branch, :year, :month, :as_of

    def initialize(config:)
      super()

      @config       = config

      @as_of  = @config[:as_of]
      @month  = @config[:month]
      @year   = @config[:year]
      @branch = @config[:branch]
    end

    def execute!
      month_prev = as_of - 1.month
      as_of_prev = Date.new(month_prev.year, month_prev.month, -1)

      repayment_rate_prev   = DataStore.repayment_rates.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{as_of_prev}",@branch.id).last
      repayment_rate        = DataStore.repayment_rates.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{@as_of}",@branch.id).last
      new_and_resigned      = DataStore.monthly_new_and_resigned.where("meta->>'branch_id' = ? and meta->>'as_of' = ?","#{@branch.id}", "#{@as_of}").last
      new_and_resigned_prev = DataStore.monthly_new_and_resigned.where("meta->>'branch_id' = ? and meta->>'as_of' = ?","#{@branch.id}", "#{as_of_prev}").last
      member_counts         = DataStore.member_counts.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{@as_of}",@branch.id).last
      member_counts_prev    = DataStore.member_counts.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{as_of_prev}",@branch.id).last

      if repayment_rate_prev.blank?
        @errors[:messages] << {
          key: "repayment_rate_prev",
          message: "No repayment rate previous found for #{as_of_prev}"
        }
      end

      if repayment_rate.blank?
        @errors[:messages] << {
          key: "repayment_rate",
          message: "No repayment rate found for #{as_of}"
        }
      end

      if new_and_resigned.blank?
        @errors[:messages] << {
          key: "new_and_resigned",
          message: "No new and resigned found for #{as_of}"
        }
      end

      if new_and_resigned_prev.blank?
        @errors[:messages] << {
          key: "new_and_resigned_prev",
          message: "No new and resigned found for previous date #{as_of_prev}"
        }
      end

      if member_counts.blank?
        @errors[:messages] << {
          key: "member_counts",
          message: "No member counts found for #{as_of}"
        }
      end

      if member_counts_prev.blank?
        @errors[:messages] << {
          key: "member_counts_prev",
          message: "No memer counts foud for previous date #{as_of_prev}"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
