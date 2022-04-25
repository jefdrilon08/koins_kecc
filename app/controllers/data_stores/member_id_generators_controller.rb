module DataStores
  class MemberIdGeneratorsController < DataStoreController
    def index
      @data_store = DataStore.where(
                                    "meta ->> 'branch_id' IN (?) AND  
                                     meta ->> 'data_store_type' = ?", 
                                     @branches.pluck(:id),
                                     "GENERATED_ID"
                                    )
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
      @data_store = DataStore.find(params[:id])
      
      branch = Branch.find(@data_store.meta["branch_id"]) 
      brach_active_center = Member.where(branch_id: branch.id, status: "active").pluck(:center_id).uniq
      @center = Center.find(brach_active_center)
      
    
      @subheader_items = [
        {
          text: "Data Stores"
        },
        {
          text: "Member ID Generator"
        }
      ]

      if @data_store.status == "pending"

        @subheader_side_actions = [
          {
            id: "btn-check",
            link: "#",
            class: "fa fa-plus",
            text: "Check"
          }
        ]
      end
      if @data_store.status == "checked"

        @subheader_side_actions = [
          {
            id: "btn-for-printing",
            link: "#",
            class: "fa fa-plus",
            text: "For Printing"
          }
        ]
      end
    end
    def for_member_id_excel
      excel = ::Reports::DownloadForMemberIdGeneratorExcel.new(report_id: params[:id]).execute!
      filename = DataStore.find(params[:id]).meta["refference_number"] 
      excel.serialize "#{Rails.root}/tmp/#{filename}"
      
    
  
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

    end
  end
end
