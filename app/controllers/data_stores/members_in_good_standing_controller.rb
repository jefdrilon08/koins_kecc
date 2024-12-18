module DataStores
	class MembersInGoodStandingController < DataStoreController
	  def destroy
	  end

	  def index
      super
      @subheader_items = [
        {
          text: "Data Store"
        },
        {
          text: "Members In Good Standing"
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
          path: "/data_stores/members_in_good_standing",
          text: "Members In Good Standing"
        }
      ]

      if @record.meta["branch"].present?
        @subheader_items << {
          text: "#{@record.meta["branch"]["name"]} #{@record.meta["year"]}"
        }
      else
        @subheader_items << {
          text: "#{@record.id}"
        }
      end
      @subheader_side_actions = []
          @subheader_side_actions << {
          id: "btn-print-pdf",
          link: "#",
          class: "fa fa-print",
          text: "Print",
          data: {
           id: "#{@record.id}"
          },
        }

        @subheader_side_actions << {
          id: "btn-excel",
          link: "#",
          class: "fa fa-download",
          text: "Download Excel",
          data: {
            id: "#{@record.id}"
          },
        }

        @subheader_side_actions << {
          id: "",
          link: "/data_stores/members_in_good_standing/#{@record.id}",
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }
      @payload = {
        id: @record.id
      }
    end

    def destroy

      data_store = DataStore.find(params[:id])
      data_store.delete
      redirect_to data_stores_members_in_good_standing_path
    end

    def excel
      if params[:id].blank?
        render json: { error: "ID is required" }, status: :unprocessable_entity
        return
      end
      data_store = DataStore.find_by(id: params[:id])
      
      if data_store.nil?
        render json: { error: "DataStore not found" }, status: :not_found
        return
      end
      render json: { download_url: data_stores_migs_download_excel_path(record: params[:id]) }
    end
    
    def members_in_good_standing_excel
      download_excel = ::MembersInGoodStanding::MigsDownloadExcel.new(record: params[:record]).execute!
      filename = "members_in_good_standing.xlsx"
      download_excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: filename, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end

	end
end
