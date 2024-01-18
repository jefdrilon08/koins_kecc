module Print
	class BuildRepaymentRates
		include ActionView::Helpers::NumberHelper

		def initialize(repayment_rate:)
			@repayment_rate 	 = repayment_rate
			@repayment_rate_data = repayment_rate.data.with_indifferent_access
			@data 				 =	{}
			@array 				 =  []
			
		end
			def execute!
				@principal = []
				@repayment_rate_data['records'].each do |rr|
					principal =  rr['principal']
					@principal << principal

				end
				@data[:tin_number]
				@data[:total_principal]							= @repayment_rate_data[:total_principal]
				@data[:total_principal_paid]					= @repayment_rate_data[:total_principal_paid]
				@data[:total_overall_principal_balance]			= @repayment_rate_data[:total_overall_principal_balance]
				@data[:total_interest]							= @repayment_rate_data[:total_interest]
				@data[:total_interest_paid]						= @repayment_rate_data[:total_interest_paid]
				@data[:total_principal_due]						= @repayment_rate_data[:total_principal_due]
				@data[:total_total_due]							= @repayment_rate_data[:total_total_due]
				@data[:total_principal_balance]					= @repayment_rate_data[:total_principal_balance]
				@data[:total_total_balance]						= @repayment_rate_data[:total_total_balance]
				@data[:total_overall_balance]					= @repayment_rate_data[:total_overall_balance]
				@data[:total_rr]								= @repayment_rate_data[:total_rr]
				@data[:total_principal_rr]						= @repayment_rate_data[:total_principal_rr]
				@data[:total_principal_paid_due]				= @repayment_rate_data[:total_principal_paid_due]
				@data[:total_interest_paid_due]					= @repayment_rate_data[:total_interest_paid_due]
				@data[:total_paid_due]							= @repayment_rate_data[:total_paid_due]
				@data[:total_total_paid]						= @repayment_rate_data[:total_total_paid]

				@data[:total_overall_interest_balance]			= @repayment_rate_data[:total_overall_interest_balance]

				@data[:loan_products]	= @repayment_rate_data[:loan_products]
				@data[:as_of] 			= @repayment_rate_data[:as_of]
				@data[:branch]			= @repayment_rate.meta['branch_name'].to_s.upcase
				
				@data[:data] 			= @repayment_rate
				@data
   		end
	end
end