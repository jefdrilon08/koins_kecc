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
				@subheader_side_actions = []

				 @subheader_side_actions << {
          id: "",
          link: "/data_stores/assets_liabilities/#{@data_store.id}",
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }

			end

			def destroy
				assets_liabilities = DataStore.find(params[:id])
				assets_liabilities.destroy!
				redirect_to "/data_stores/assets_liabilities"
			end
		
		end
end