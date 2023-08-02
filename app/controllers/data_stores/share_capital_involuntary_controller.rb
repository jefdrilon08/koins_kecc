module DataStores
	class ShareCapitalInvoluntaryController < DataStoreController
		def index 
			super

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
		super
		@details = params[:data]
		@data_store = DataStore.find(params[:id])
		@records = @data_store.data.with_indifferent_access[:records].reject(&:blank?)
	
		@subheader_side_actions = []
			@subheader_side_actions << {
	          id: "",
	          link: "/data_stores/involuntary_members/#{@record.id}",
	          class: "fa fa-times",
	          data: {
	            method: :delete,
	            confirm: "Are you sure?"
	          },
	          text: "Delete"
	        }
	   @subheader_side_actions << {
	          id: "btn-print-list",
	          link: "#",
	          class: "fa fa-download",
	          data: {
              id: "#{@record.id}"
            },
	          text: "Print Master List"
	        }
		      @payload = {
		        id: @record.id
		      }


		     
			
		end





	end
end
