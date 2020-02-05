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

      repayment_rate_prev   = find_data_stores :repayment_rates,          as_of_prev, :meta
      repayment_rate        = find_data_stores :repayment_rates,          as_of,      :meta
      new_and_resigned      = find_data_stores :monthly_new_and_resigned, as_of,      :meta
      new_and_resigned_prev = find_data_stores :monthly_new_and_resigned, as_of_prev, :meta
      member_counts         = find_data_stores :member_counts,            as_of,      :data
      member_counts_prev    = find_data_stores :member_counts,            as_of_prev, :data

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

    private

    def find_data_stores(scope, date, meta_or_data)
      ds = if meta_or_data == :meta
             DataStore.send(scope)
               .where("meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS DATE) <= ?", branch.id, date)
               .order("CAST(meta->>'as_of' AS DATE) ASC")
               .last
           else
             DataStore.send(scope)
               .where("data->'branch'->>'id' = ? AND CAST(data->>'as_of' AS DATE) <= ?", branch.id, date)
               .order("CAST(data->>'as_of' AS DATE) ASC")
               .last
           end

      ds_date = ds.try!(:meta).dig("as_of").try!(:to_date)

      if ds_date.year == date.year && ds_date.month == date.month
        return ds
      else
        return nil
      end
    end
  end
end
