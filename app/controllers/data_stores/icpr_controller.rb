module DataStores
  class IcprController < DataStoreController
    def index
      super

      branch_id = params[:branch_id]
      status = params[:status]

      if branch_id.present?
        @record = @records.where(branch_id: branch_id)
      end

      if status.present?
        @records = @records.where(status: status)
      end

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
      @subheader_side_actions = []
      
      @subheader_side_actions << {
          id: "btn-print-pdf",
          link: "#",
          class: "fa fa-download",
          text: "Print PDF",
          data: {
            id: "#{@record.id}"
          }
        }

      if @record.pending? and @record.data["status"] == "pending"
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

        @subheader_side_actions << {
          id: "btn-print",
          link: "#",
          class: "fa fa-print",
          text: "Print Entry",
          data: {
            id: "#{@record.id}"
          }
        }
      else
        @subheader_side_actions << {
          id: "btn-print",
          link: "#",
          class: "fa fa-print",
          text: "Print Entry",
          data: {
            id: "#{@record.id}"
          }
        }
      end

      @payload = {
        id: @record.id
      }
    end
  end
end
