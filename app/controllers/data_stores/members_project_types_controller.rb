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
      @data_store_data = @data_store.data
      @branch = @data_store_meta[:branch_id]
      @center = @data_store_meta[:center_id]
      @member_list = Member.where(branch_id: @branch, center_id: @center).map{ |o| ["#{o["last_name"]}, #{o["first_name"]}", o["id"] ]   }
      @project_type_category = ProjectTypeCategory.where(is_active: "true").map{ |o| ["#{o["name"]}", o["id"] ]   }
      
      @subheader_items  = [
        {
          text: "Member Project Type"
        }
        ]
      @subheader_side_actions = []
      
      if @data_store.pending?

        @subheader_side_actions << {
          
            id: "btn-approve",
            link: "#",
            class: "fa fa-plus",
            text: "Approve"
          
        }
        
        @subheader_side_actions << {
          
            id: "",
            link: "/data_stores/members_project_types/#{@data_store.id}",
            class: "fa fa-times",
            data: {
              method: :delete,
              confirm: "Are you sure to delete record?"

            },
            text: "Delete"
          
        }
      end
      
      @payload = {
        id: @data_store.id
      }
    end
  end
end
