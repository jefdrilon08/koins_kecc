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

    def details_data
      @data_store = DataStore.find(params[:id])
      @prcategory = ProjectTypeCategory.find(params[:categ])
      @data_category_details = ProjectType.find(params[:cated_details])
      
      h = @data_store.data.select{ |c| c["cated_id"] == @prcategory.id  }
      
      @cdet  = h[0]["categ"].select{ |cc| cc["det_id"]  == @data_category_details.id   }

      #raise cdet[0]["memDet"].inspect

    end

  end
end
