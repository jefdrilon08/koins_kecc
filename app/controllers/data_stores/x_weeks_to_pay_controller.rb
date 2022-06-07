module DataStores
  class XWeeksToPayController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "X Weeks to Pay" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" }
      ]
    end

    def show
      super

      @meta = @record.meta.try(:with_indifferent_access)
      @data = @record.data.try(:with_indifferent_access)

      @subheader_items = [
        { text: "Data Stores" },
        { text: "X Weeks to Pay", is_link: true, path:  "/data_stores/x_weeks_to_pay" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.data["branch"]["name"]}"
        }

        @subheader_items << {
          text: "As Of: #{@record.data.with_indifferent_access[:as_of].to_date.strftime("%B %d, %Y")} until #{@record.data.with_indifferent_access[:date_until].to_date.strftime("%B %d, %Y")} (#{@record.data.with_indifferent_access[:x]} Weeks)"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/x_weeks_to_pay/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id
      }
    end
  end
end
