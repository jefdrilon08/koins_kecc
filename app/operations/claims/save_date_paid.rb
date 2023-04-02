module Claims
	class SaveDatePaid
		def initialize(config:)
			super()
			 @config = config

			 @date_paid 		= @config[:date_paid]
			 @claim 			= @config[:claim]
			 @data 				= @claim.data.with_indifferent_access
			 @accounting_entry 	= @data[:accounting_entry]
		end

		def execute!
			@accounting_entry[:data][:date_paid] = @date_paid

			@data[:accounting_entry] = @accounting_entry
			
			@claim.update!(data: @data)
			
			@claim
		end
	end
end