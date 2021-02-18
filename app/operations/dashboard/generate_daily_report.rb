module Dashboard
  class GenerateDailyReport
    attr_accessor :branch, :as_of

    def initialize(config:)
      @config = config

      @branch = @config[:branch]
      @as_of  = @config[:as_of]
    end

    def execute!
      ##### RR ####
      record  = DataStore.select("id, meta, status").where(
                  "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ? AND meta->>'data_store_type' = ?",
                  branch.id,
                  as_of,
                  "REPAYMENT_RATES"
                ).first

      if record.blank?
        record  = DataStore.create!(
                    meta: {
                      branch_id: branch.id,
                      branch_name: branch.name,
                      as_of: as_of,
                      data_store_type: "REPAYMENT_RATES"
                    },
                    data: {
                      status: "processing"
                    }
                  )
      else
        record.update!(status: "processing")
      end

      args = {
        id: record.id,
        data_store_type: "REPAYMENT_RATES"
      }

      ProcessRepaymentRates.perform_later(args)

      ##### MEMBER COUNTS ####
      record  = ReadOnlyDataStore
                .select("id, status, as_of, meta")
                .member_counts.where(
                  "meta->>'branch_id' = ? AND as_of = ?",
                  branch.id,
                  as_of
                ).first

      if record.blank?
        record  = DataStore.create!(
                    status: "processing",
                    meta: {
                      branch_id: branch.id,
                      branch_name: branch.name,
                      branch: {
                        id: branch.id,
                        name: branch.name
                      },
                      as_of: as_of,
                      data_store_type: "MEMBER_COUNTS"
                    },
                    data: {
                      status: "processing"
                    }
                  )
      else
        record.update!(status: "processing")
      end

      args  = {
        record_id: record.id,
        data_store_type: "MEMBER_COUNTS"
      }

      ProcessBranchMemberCounts.perform_later(args)
    end
  end
end
