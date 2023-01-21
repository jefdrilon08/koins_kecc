module DataStores
	class MembersProjectTypesController < DataStoreController
    
    def index
      
      @data_stores = DataStore.select("*").where("meta ->> 'branch_id' in (?) and meta ->> 'data_store_type' = ?", @branches.pluck(:id), "PROJECT TYPE" ) 

      
     
      @subheader_items = [
        {
          text: "Update Member Project Type"
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
      @data_store_meta = @data_store.meta.with_indifferent_access
      @branch = @data_store_meta[:branch_id]
      @center = @data_store_meta[:center_id]
      @member_list = Member.where(branch_id: @branch, center_id: @center).map{ |o| ["#{o["last_name"]}, #{o["first_name"]}", o["id"] ]   }
      @project_type_category = ProjectTypeCategory.all.map{ |o| ["#{o["name"]}", o["id"] ]   }
    end
  end
end
