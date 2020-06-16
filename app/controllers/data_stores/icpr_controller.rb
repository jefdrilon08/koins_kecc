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

      @subheader_items = [
        {
          is_link: true,
          path: "/data_stores/icpr",
          text: "ICPR"
        }
      ]

      if @record.data["branch"].present?
        @subheader_items << {
          text: "#{@record.data["branch"]["name"]} #{@record.meta["year"]}"
        }
      else
        @subheader_items << {
          text: "#{@record.id}"
        }
      end

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]

      if @record.done? and @record.data["status"] == "pending"
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }

        @subheader_side_actions << {
          id: "btn-set-rate",
          link: "#",
          class: "fa fa-upload",
          text: "Set Rate"
        }

        @subheader_side_actions << {
          id: "",
          link: "/data_stores/icpr/#{@record.id}",
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }
      end

      @payload = {
        id: @record.id
      }
    end
  end
end
