module DataStores
  class MemberIdGeneratorsController < DataStoreController
    def index
      @subheader_items = [
        {
          text: "Data Stores"
        },
        {
          text: "Member ID Generator"
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
      data_store = DataStore.find(params[:id])
      branch = Branch.find(data_store.meta["branch_id"]) 
      @center = Center.where(branch_id: branch.id)
      
    
      @subheader_items = [
        {
          text: "Data Stores"
        },
        {
          text: "Member ID Generator"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-check",
          link: "#",
          class: "fa fa-plus",
          text: "check"
        }
      ]
    end
  end
end
