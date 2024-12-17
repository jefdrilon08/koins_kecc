module DataStores
  class ManualAgingController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Manual Aging" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" }
      ]
    end

    def show
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Manual Aging", is_link: true, path:  "/data_stores/manual_aging" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.data["branch"]["name"]} - #{@record.data["as_of"].to_date.strftime("%B %d, %Y")}"
        }
      end
      
      @subheader_side_actions = []

      if is_mis_user?
      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/manual_aging/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]
      end

      @payload = {
        id: @record.id
      }
    end

    private

    def is_mis_user?
      current_user&.roles&.include?('MIS')
    end
  end
end
