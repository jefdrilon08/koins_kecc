module DataStores
  class IcprController < DataStoreController
    def index
      super

      @subheader_items = [
        {
          text: "Data Stores"
        },
        {
          text: "ICPR"
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

      @payload = {
        id: @record.id
      }
    end
  end
end
