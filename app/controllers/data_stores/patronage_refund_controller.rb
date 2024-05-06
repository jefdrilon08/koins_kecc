module DataStores
  class PatronageRefundController < DataStoreController

    def index
      @record = ReadOnlyDataStore.patronage_refund

      @year = params[:year]
      @branch_id = params[:branch_id] 
      
      if @year.present?
        @record = @record.where("meta->>'year' = ?", @year)
      end   
     
      if @branch_id.present?
        @record = @record.where("meta->>'branch_id' = ?", @branch_id)
      end

      @record = @record.order(Arel.sql("meta->>'year' DESC")).page(params[:page]).per(20)
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
          is_link: true,
          path: "/data_stores/patronage_refund",
          text: "patronage refund"
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
      if @record[:status] == "pending"
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
          link: "/data_stores/patronage_refund/#{@record.id}",
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
