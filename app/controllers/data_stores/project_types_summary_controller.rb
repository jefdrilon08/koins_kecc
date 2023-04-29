module DataStores
  class ProjectTypesSummaryController < DataStoreController
    def index
      
      @data_store = DataStore.where(
                                    "meta ->> 'branch_id' IN (?) AND  
                                     meta ->> 'data_store_type' = ?" , 
                                     @branches.pluck(:id),
                                     "PROJECT_TYPE_SUMMARY"
                                    )

      @data_store_meta = @data_store.last.meta.with_indifferent_access



      @subheader_items = [
        {
          text: "Data Store"
        },
        {
          text: "Members For Writeoff"
        }
      ]


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
      @branch_name = Branch.find(@data_store.meta["branch_id"]).name

    end

  end
end
