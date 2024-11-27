module DataStores
  class DormantController < DataStoreController

    def index
      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
      @records = DataStore.where("meta ->> ? = ?", 'data_store_type', 'DORMANT')

      branch_id = params[:branch_id]
      as_of_date = params[:date]

      # Filter by Branch
      if params[:branch_id].present?
        @records = @records.where("meta ->> ? = ?", 'branch_id', params[:branch_id])
        @no_records_message = "No records found for the selected branch." if @records.empty?
      end

      # Filter by date if an "as of"
      if params[:date].present?
        @records = @records.where("created_at <= ?", Date.parse(params[:date]))
      end

      if @status.present?
        @records = @records.where(status: @status)
      end

      @records = @records.order(created_at: :desc)
                         .page(params[:page])
                         .per(10)
    end

    def show
      @data_store = DataStore.find(params[:id])
      @data = @data_store.data.with_indifferent_access
      Rails.logger.debug "Params ID: #{params[:id]}"
      # Rails.logger.debug "DataStore Found: #{@data_store.present?}"
      @accounting_entry = @data[:accounting_entry]

      @dormant_records = if @data[:record].present?
        @data[:record]
      else
        []
      end

      # Sort the dormant records by center_name
      @dormant_records.sort_by! do |record|
        center_name = record[:center_name]
        center_name.scan(/\d+|\D+/).map do |part|
          part.match?(/\d+/) ? part.to_i : part.downcase
        end
      end

      @total_balance = @dormant_records.sum { |record| record[:balance].to_f }
      @total_dormant_fee = @dormant_records.sum { |record| record[:dormant_fee].to_f }

      @subheader_side_actions ||= []

      unless ["approved", "processing"].include?(@data_store.status)
        @subheader_side_actions << {
          id: "btn-delete",
          # link: "",
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure you want to delete this Dormant Record?"
          },
          text: "Delete"
        }

        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          data: { id: @data_store.id },
          text: "Approve"
        }

        @subheader_side_actions << {
          id: "btn-print",
          link: "#",
          class: "fa fa-print",
          text: "Print",
          data: {
            id: "#{@data_store.id}"
           },
        }
        @subheader_side_actions << {
          id: "btn-excel",
          link: "#",
          class: "fa fa-download",
          text: "Download Excel",
          data: {
            id: "#{@data_store.id}" # Ensure data-id is set
          },
        }
      end
    end

    def destroy
      @data_store = DataStore.find(params[:id])

      if @data_store.pending? || @data_store.error?
        @data_store.destroy
        redirect_to data_stores_dormant_path
      else
        redirect_to data_stores_dormant_path
      end
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
    
      render json: { download_url: data_stores_dormant_download_excel_path(record: params[:id]) }
    end
    
    def dormant_excel
      #  Rails.logger.debug "DATASTORE DATA: #{data_store.inspect}"
      download_excel = ::Dormants::DormantDownloadExcel.new(record: params[:record]).execute!
      filename = "dormant.xlsx"
      download_excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: filename, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end

    
  end
end