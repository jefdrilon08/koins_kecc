module DataStores
  class MonthlyNewAndResignedController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Monthly New And Resigned" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" }
      ]
    end

    def show
      super
      @data = @record.data.with_indifferent_access

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Monthly New And Resigned", is_link: true, path: "/data_stores/monthly_new_and_resigned" }
      ]

      if @record.data["branch"].present?
        @subheader_items << {
          text: "#{@record.data["branch"]["name"]}"
        }

        if @record.done?
          @subheader_items << {
            text: "As Of: #{@record.data["as_of"].to_date.strftime("%B %d, %Y")}"
          }
        end
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/monthly_new_and_resigned/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]
    end
  end
end
