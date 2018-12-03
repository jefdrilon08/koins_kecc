class ProcessBranchLoansStats < ApplicationJob
  queue_as :default

  def perform(args)
    record  = args[:record]

    file    = args[:file]
    branch  = Branch.find(record.meta.with_indifferent_access[:branch_id])
    as_of   = record.meta.with_indifferent_access[:as_of].to_date

    record.update!(status: "processing")

    begin 
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
    rescue
      record.update!(
        status: "error"
      )
    end
  end
end
