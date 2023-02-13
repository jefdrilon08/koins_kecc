module DataStores
	class ShareCapitalSummaryController < DataStoreController
		def index
			

			@records = DataStore.where("meta ->> 'branch_id' IN (?) AND 
							    meta ->> 'data_store_type' = 'SHARE_CAPITAL_SUMMARY'", @branches.pluck(:id))

			@subheader_side_actions = [{ 
 			text: "Generate New", 
 			link: "#", 
 			class: "fa fa-plus", 
 			id: "btn-new"}]			
		end
		def show
			super

			@payload = {
        id: @record.id
      }
		end
	end
end
