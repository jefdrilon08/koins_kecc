class ProcessBranchLoansStats < ApplicationJob
  queue_as "process_branch_loans_stats"

  def perform(args)
    record  = args[:record]
    branch  = Branch.find(record.meta.with_indifferent_access[:branch_id])
    as_of   = record.meta.with_indifferent_access[:as_of].to_date

    record.update!(status: "processing")

    config  = {
      id: record.id,
      branch: branch,
      as_of: as_of,
      include_centers: args[:include_centers],
      data_store_type: args[:data_store_type]
    }

    data_store  = ::DataStores::SaveBranchLoansStats.new(
                    config: config
                  ).execute!
  end
end
