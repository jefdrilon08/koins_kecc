module DataStores
  class MonthlyIncentivesController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Monthly Incentives" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" }
      ]
    end

    def show
      super

      @meta = @record.meta.try(:with_indifferent_access)
      @data = @record.data.with_indifferent_access
      @data_records = @record.data.with_indifferent_access[:records]
      @subheader_items = [
        { text: "Data Stores" },
        { text: "Monthly Incentives", is_link: true, path:  "/data_stores/monthly_incentives" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@meta[:branch_name]} - #{@meta[:as_of].to_date.strftime("%B %d, %Y")}"
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
      @subheader_side_actions <<  { 
        text: "Delete", class: "fa fa-times", 
        link: "/data_stores/monthly_incentives/#{@record.id}", 
        data: { method: :delete, confirm: "Are you sure?" }
        }
        
        @subheader_side_actions << {
          link: "#",  
          # link:"#{data_stores_monthly_incentives_download_excel_path(record: params[:id])}",
          # method:monthly_incentives_excel,
          class: "fa fa-download",
          id: "btn-dl-excel",
          text: "Download Excel",
          data:
          {
            id:"#{@record.id}",
          }
          
        }

      @payload = {
        id: @record.id
      }
    end

    def excel
      
      puts "hahahahahahahahahaah"
      # download_excel = ::DataStores::GenerateMonthlyIncentivesExcel.new(meta: @meta,data: @data).execute!
      @download_excel =::DataStores::GenerateMonthlyIncentivesExcel.new(config: params[:id]).execute!
      a=ReadOnlyDataStore.find(params[:id])
      @branch=a[:meta]["branch_name"]
      @endDate=a[:meta]["as_of"]
      # render json: @download_excel
      @filename = "Monthly_Incentives - #{@branch} #{@endDate}.xlsx"
      send_data @download_excel,filename:@filename
    end

  end
end
