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

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Allowance Computation" }
      ]
      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/allowance_computation_report/#{@record.id}", data: { method: :delete, confirm: "Are you sure you want to delete this report?" } }
      ]



      @payload = {
        id: @record.id
      }
    end
  
  end

end
