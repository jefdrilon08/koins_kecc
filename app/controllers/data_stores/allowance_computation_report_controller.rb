module DataStores
  class AllowanceComputationReportController < DataStoreController
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
      
      data = ReadOnlyDataStore.where("meta ->> 'data_store_type' = 'ALLOWANCE_COMPUTATION'")
      @records = data.page(params[:page]).per(LIST_PAGE_SIZE)
    end  

    def show
      #super
      @record = DataStore.find(params[:id])
      @payload = {
        id: @record.id
      }
    end
  
  end

end
