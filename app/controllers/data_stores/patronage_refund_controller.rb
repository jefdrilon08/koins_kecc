module DataStores
  class PatronageRefundController < DataStoreController
    def index
      super

      @subheader_items = [
        {
          text: "Data Stores"
        },
        {
          text: "Patronage Refund"
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
          text: "Data Stores"
        },
        {
          is_link: true,
          path: "/data_stores/patronage_refund",
          text: "Patronage Refund"
        }
      ]

      if @record.data["branch"].present?
        @subheader_items << {
          text: "#{@record.data["branch"]["name"]}"
        }
      else
        @subheader_items << {
          text: "#{@record.id}"
        }
      end

      @subheader_side_actions = []

      if @record.done?
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }

        @subheader_side_actions << {
          id: "",
          link: "/data_stores/patronage_refund/#{@record.id}",
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
