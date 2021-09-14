module Print
	class BuildPrintIcpr
	include ActionView::Helpers::NumberHelper
		def initialize(icpr)
		  @icpr = icpr 	
		end 
		def execute!
			 	@branch_name = @icpr[:icpr][:meta]["branch_name"]
			 	@year        = @icpr[:icpr][:meta]["year"]
			 	ds_type      = @icpr[:icpr][:meta]["data_store_type"]
			 if ds_type == "PATRONAGE_REFUND"
			 	@type = "PATRONAGE REFUND"
			 	
			 	@data = {
			 		branch_name: @branch_name,
			 		year: @year,
			 		type: @type,
			 		record: []
			 	}
			 	@data[:record] = @icpr[:icpr][:data]["records"].map{ |o|
			 		temp = {
			 			first_name: o.fetch("first_name"),
		                middle_name: o.fetch("middle_name"),
		                last_name: o.fetch("last_name"),
		                identification_number: o.fetch("identification_number"),
		                center_id: o["center"]["id"],
		                center_name: o["center"]["name"],	                         
		                patronage_interest_amount: o.fetch("patronage_interest_amount"),
		                savings_distribute: o.fetch("savings_distribute"),
		                cbu_distribute: o.fetch("cbu_distribute")
			 		}
			 		temp
				}
				@data[:record] = @data[:record].sort_by { |hash|hash[:center_id]}
				@data 

		 	else
		 		@type = "INTEREST ON SHARE CAPITAL"
		 		@data = {
		 		branch_name: @branch_name,
		 		year: @year,
		 		type: @type,
		 		record: []
		 		}
		 		@data[:record] = @icpr[:icpr][:data]["records"].map{ |o|
		 		temp = {
		 			first_name: o.fetch("first_name"),
	                middle_name: o.fetch("middle_name"),
	                last_name: o.fetch("last_name"),
	                identification_number: o.fetch("identification_number"),
	                center_id: o["center"]["id"],
	                center_name: o["center"]["name"],	                         
	                equity_interest_amount: o.fetch("equity_interest_amount"),
	                savings_distribute: o.fetch("savings_distribute"),
	                cbu_distribute: o.fetch("cbu_distribute")
		 			}
		 			temp
		 		}
				@data[:record] = @data[:record].sort_by { |hash|hash[:center_id]}
		 		@data 
		 	end

		end
	end
end