module DataStores
  class ProjectTypesSummaryController < DataStoreController
    def index
      @data_store = DataStore.where(
                                    "meta ->> 'branch_id' IN (?) AND  
                                     meta ->> 'data_store_type' = ?" , 
                                     @branches.pluck(:id),
                                     "PROJECT_TYPE_SUMMARY"
                                    )
                                    #Filter data_store by branch_id if branch_id is present
                                    if params[:branch_id].present?
                                      @data_store = @data_store.where("meta ->> 'branch_id' = ?", params[:branch_id])
                                    end

                                    #Add start and end date filters
                                    if params[:start_date].present? && params[:end_date].present?
                                      start_date = params[:start_date]
                                      end_date = params[:end_date]
                                      
                                      @data_store = @data_store.where(
                                        "created_at BETWEEN ? AND ?", 
                                        start_date, 
                                        end_date                              
                                      )
                                    end




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

    end

  end
end