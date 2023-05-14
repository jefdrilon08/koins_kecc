module DataStores
		class AssetsLiabilitiesController < DataStoreController
			def index
			
				@records = DataStore.assets_liabilities
				  @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
			end

			def show
				@data_store = DataStore.find(params[:id])
				@data = @data_store.data.with_indifferent_access

				
			
				

			end
		
		end
end