module DataStores
	class PrintInvoluntaryMembers
		def initialize(config:)
			@data_store = DataStore.find(config[:data_store_id])
			@member_id = Member.find(config[:member_id])
		end

		def execute
			raise 
		end
	end
end