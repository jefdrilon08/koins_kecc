module DataStores
  class BranchResignationsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Branch Resignations" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" }
      ]
    end

    def show
      super

      @meta = @record.meta.with_indifferent_access
      @data = @record.data.with_indifferent_access

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Branch Resignations", is_link: true, path:  "/data_stores/soa_funds" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@data[:branch].fetch(:name)} - #{@meta[:start_date].try(:to_date).try(:strftime, "%B %d, %Y")} to #{@meta[:end_date].try(:to_date).try(:strftime, "%B %d, %Y")}"
        }
        
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/soa_funds/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id
      }
    end
  end
end
