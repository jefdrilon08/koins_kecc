module DataStores
	class InvoluntaryMembersController < DataStoreController
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
		@records = @data_store.data.with_indifferent_access[:record].reject(&:blank?)
		@subheader_side_actions = []
			@subheader_side_actions << {
	          id: "",
	          link: "/data_stores/members_in_good_standing/#{@record.id}",
	          class: "fa fa-times",
	          data: {
	            method: :delete,
	            confirm: "Are you sure?"
	          },
	          text: "Delete"
	        }
		      @payload = {
		        id: @record.id
		      }


		     
			
		end





	end
end
