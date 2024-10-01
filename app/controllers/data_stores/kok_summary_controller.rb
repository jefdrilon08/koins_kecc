module DataStores
  class KokSummaryController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Kok Summary" }
      ]
    end

    def show
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Kok Summary", is_link: true, path:  "/data_stores/kok_summary" }
      ]

      if !@record.error?
        @subheader_items << {
          # text: "#{@record.data["branch"]["name"]} - #{@record.data["as_of"].to_date.strftime("%B %d, %Y")}"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/kok_summary/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id
      }
    end
  end
end
