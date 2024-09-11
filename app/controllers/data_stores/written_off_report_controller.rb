module DataStores
    class WrittenOffReportController < DataStoreController
      def index
        @subheader_side_actions = [
          {
            id: "btn-new",
            link: "#",
            class: "fa fa-plus",
            text: "New"
            
          }
        ]
        @datastore = DataStore.where("meta ->> ? = ?", "data_store_type", "WRITTEN_OFF_REPORT").order(created_at: :desc)
      end
  
      def show
        @datastore = DataStore.find(params[:id])
        @branch_name = @datastore.meta['branch_name']
        @data_record = @datastore.data['records']
        @subheader_side_actions = [
          {
            id: "btn-arrow-left",
            link: "/data_stores/written_off_report",
            class: "fa fa-arrow-left",
            text: "Written-Off Report"
          },
          {
            id: "btn-delete",
            link: "#",
            class: "fa fa-trash",
            text: "Delete",
            data: { id: params[:id] }
          }
        ]
      end
      
    end
  end
  