class ProcessImportInsuranceAccountTransaction < ApplicationJob
	queue_as :default

	def perform(args)
		# create background operation with status, processing, started_at, ended_at
		file        = args[:file]
    data_store  = DataStore.find(args[:data_store_id])

		begin
      Insurance::ImportInsuranceAccountTransactionsFromCsvFile.new(file: file).execute!
	
      data            = data_store.data.with_indifferent_access
      data[:time_end] = Time.now

      data_store.update!(
        status: "done",
        data: data
      )
		rescue Exception => e
			data_store.update!(
				status: "error",
				data: {
					exception: e
				}
			)
		end
	end
end
