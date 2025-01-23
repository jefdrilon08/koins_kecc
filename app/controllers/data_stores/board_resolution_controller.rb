module DataStores
    class BoardResolutionController < DataStoreController
  
      def index
        @subheader_side_actions = [
          {
            id: "btn-new",
            link: "#",
            class: "fa fa-plus",
            text: "New"
          }
        ]
        @records = DataStore.where("meta ->> ? = ?", 'data_store_type', 'BOARD_RESOLUTION')
  
        branch_id = params[:branch_id]
        date_from = params[:date]
        date_to = params[:date]
        

    end
  end
  