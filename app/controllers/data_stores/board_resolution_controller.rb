module DataStores
    class BoardResolutionController < DataStoreController
  
      def index
        @subheader_side_actions = [
          {
            id: "btn-new",
            link: "#",
            class: "fa fa-plus",
            text: "New"
          }
        ]
        @records = DataStore.where("meta ->> ? = ?", 'data_store_type', 'BOARD_RESOLUTION')

        # branch_id = params[:branch_id]
        month = params[:month] 
        year = params[:year]
        board_resolution_number = params[:board_resolution_number]  

        # Filter by Branch
      # if params[:branch_id].present?
      #   @records = @records.where("meta ->> ? = ?", 'branch_id', params[:branch_id])
      #   @no_records_message = "No records found for the selected branch." if @records.empty?
      # end

      # Filter by Month
      if month.present?
        @records = @records.where("meta ->> ? = ?", 'month', month)
      end

      # Filter by Year
      if year.present?
        @records = @records.where("meta ->> ? = ?", 'year', year.to_s)  # Convert year to string for comparison
      end
          
      end

      def show
        @data_store = DataStore.find(params[:id])
        @data = @data_store.data.with_indifferent_access

        @records = if @data[:record].present?
          @data[:record]
        else
          [] 
        end

        @subheader_side_actions ||= []

        unless ["approved", "processing"].include?(@data_store.status)
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          data: { id: @data_store.id },
          text: "Approve"
        }
      end
    end

    end
  end
  