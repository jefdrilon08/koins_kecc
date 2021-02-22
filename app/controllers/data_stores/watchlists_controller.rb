module DataStores
  class WatchlistsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Watchlists" }
      ]

      @subheader_side_actions = [
      ]
    end

    def show
      super

      @meta = @record.meta.with_indifferent_access
      @data = @record.data.with_indifferent_access

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Watchlists", is_link: true, path:  "/data_stores/watchlists" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.data.with_indifferent_access[:branch][:name]} - #{@record.meta.with_indifferent_access[:as_of].to_date.strftime("%B %d, %Y")}"
        }
      end

      @subheader_side_actions = [
      ]

      @payload = {
        id: @record.id
      }
    end
  end
end
