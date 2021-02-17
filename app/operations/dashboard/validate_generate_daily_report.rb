module Dashboard
  class ValidateGenerateDailyReport < AppValidator
    attr_accessor :errors

    def initialize(config:)
      super()

      @config = config

      @branch_id  = @config[:branch_id]
      @as_of      = @config[:as_of].try(:to_date)
    end

    def execute!
      #not_yet_implemented!

      if @branch_id.blank?
        @errors[:messages] << {
          key: "branch_id",
          message: "Branch required"
        }
      end

      if @as_of.blank?
        @errors[:messages] << {
          key: "as_of",
          message: "As of date required"
        }
      end

      if @branch_id.present? and @as_of.present?
        latest_processing_rr  = ReadOnlyDataStore.select(
                                  "id, status, meta, as_of"
                                ).repayment_rates.where(
                                  "meta->>'branch_id' = ? AND as_of = ? AND status = ?",
                                  @branch_id,
                                  @as_of,
                                  "processing"
                                ).first

        if latest_processing_rr.present?
          @errors[:messages] << {
            key: "rr_report",
            message: "Pending repayment report detected"
          }
        end

        latest_member_count = ReadOnlyDataStore.select(
                                "id, status, meta, as_of"
                              ).member_counts.where(
                                "meta->>'branch_id' = ? AND as_of = ? AND status = ?",
                                @branch_id,
                                @as_of,
                                "processing"
                              ).first

        if latest_member_count.present?
          @errors[:messages] << {
            key: "member_count",
            message: "Pending member count detected"
          }
        end
      end
      
      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
