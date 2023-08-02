module Print
	class BuildShareCapitalInvoluntaryMasterList
		def initialize(config:)
			@data_store= DataStore.find(config)
		end

		def execute!
			@data = {
				records: []
			}

			@data_store[:data]["records"].each do |rec|
				if rec !=nil
					
					@data[:records] << {
						identification_number: rec["identification_number"],
						member_name: rec["member_name"],
						center: Member.find(rec["member_id"]).center.name
					}
			
				end
			end
			@data
		end


	end
end