module DataStores
	class ForWriteoffController < DataStoreController
	  
    def destroy
      @for_writeoff = DataStore.find(params[:id])
      @for_writeoff.destroy!
      redirect_to "/data_stores/for_writeoff"
	  end

	  def index
      super
      
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
      super
    

      @subheader_items = [
        {
          is_link: true,
          path: "/data_stores/for_writeoff",
          text: "Members For Writeoff"
        }
      ]

      if @record.meta["branch"].present?
        @subheader_items << {
          text: "#{@record.meta["branch"]["name"]} Loans - #{@record.meta["year"]}"
        }
      else
        @subheader_items << {
          text: "#{@record.id}"
        }
      end
      @subheader_side_actions = []
        @subheader_side_actions << {
          id: "",
          link: "/data_stores/for_writeoff/#{@record.id}",
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }
        @subheader_side_actions << {
        link: "#",
        class: "fa fa-download",
        id: "btn-excel",
        text: "Download Excel"
        }


      @payload = {
        id: @record.id
      }

    end
    def excel
    render json: {download_url: "#{data_stores_for_writeoff_download_excel_path(record: params[:id])}"} 
    end
    

    def for_writeoff_excel
      download_excel = ::Reports::DownloadForWriteoffExcel.new(record: params[:record]).execute!
      branch_name = DataStore.find(params[:record]).meta["branch_name"]
      filename = "for_writeoff_#{branch_name}.xlsx"
      download_excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
     
    end

	end
end
