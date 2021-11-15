module DataStores
	class ForWriteoffController < DataStoreController
	  
    def destroy
	  end

	  def index
      super
      @subheader_items = [
        {
          text: "Data Store"
        },
        {
          text: "Members For Writeoff"
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
          path: "/data_stores/for_writeoff",
          text: "Members For Writeoff"
        }
      ]

      if @record.meta["branch"].present?
        @subheader_items << {
          text: "#{@record.meta["branch"]["name"]} Loans - #{@record.meta["year"]}"
        }
      else
        @subheader_items << {
          text: "#{@record.id}"
        }
      end
      @subheader_side_actions = []
        @subheader_side_actions << {
          id: "",
          link: "/data_stores/for_writeoff/#{@record.id}",
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }
        @subheader_side_actions << {
          id: "btn-print-pdf",
          link: "#",
          class: "fa fa-print",
          text: "Print",
          data: {
            id: "#{@record.id}"
          }
        }
      @payload = {
        id: @record.id
      }
    end


	end
end
