class ProcessImportInsuranceAccountTransaction < ApplicationJob
	queue_as :default

	def perform(args)
		# create background operation with status, processing, started_at, ended_at
		file = args[:file]
		user_full_name = args[:user_full_name]

		# background_operation = BackgroundOperation.create!(
		# 			status: "processing",
		# 			operation_type: "IMPORT_INSURANCE_ACCOUNT_TRANSACTION_FROM_CSV_FILE",
		# 			started_at: Time.now,
		# 			prepared_by: user_full_name,
		# 			data: {
		# 				file: file
		# 			}
		# 	)
		
		# call operation
		begin
			# update background operation status
			InsuranceTransactions::ImportInsuranceAccountTransactionsFromCsvFile.new(file: file).execute!
		
			background_operation.update!(
				status: "done",
				ended_at: Time.now
			)
		rescue Exception => e
			background_operation.update!(
				status: "error",
				data: {
					exception: e
				}
			)
		end
	end
end