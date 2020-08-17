module DataStores
  class ValidateSoaFundsQueue < AppValidator
    def initialize(config:)
      super()

      @config = config

      @branch     = @config[:branch]
      @start_date = @config[:start_date].try(:to_date)
      @end_date   = @config[:end_date].try(:to_date)
    end

    def execute!
      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Branch not found"
        }
      elsif @branch.present?
        is_cutoff = ::Utils::IsCutoff.new(branch: @branch).execute!

        if !is_cutoff
          @errors[:messages] << {
            key: "cut_off",
            message: "Not yet cutoff period"
          }
        end
      end

      if @start_date.blank?
        @errors[:messages] << {
          key: "start_date",
          message: "Start date required"
        }
      end

      if @end_date.blank?
        @errors[:messages] << {
          key: "end_date",
          message: "End date required"
        }
      end

      if @start_date.present? and @end_date.present? and @start_date > @end_date
        @errors[:messages] << {
          key: "start_date",
          message: "Invalid start date #{@start_date}"
        }

        @errors[:messages] << {
          key: "end_date",
          message: "Invalid end date #{@end_date}"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end

      @errors
    end
  end
end
