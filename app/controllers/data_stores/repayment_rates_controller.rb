module DataStores
  class RepaymentRatesController < DataStoreController
    def index
      super
      @data_store = DataStore
      @subheader_items = [
        { text: "Data Stores" },
        { text: "Repayment Rates", is_link: true, path:  "/data_stores/repayment_rates" }
      ]

      @subheader_side_actions = [
      ]

      @payload = {
        urlQueue: "#{ENV['BACKEND_API_URL']}/api/v1/data_stores/repayment_rates/queue",
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end

    def show
      super
      @subheader_items = [
        { text: "Data Stores" },
        { text: "Repayment Rates", is_link: true, path:  "/data_stores/repayment_rates" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.meta["branch_name"]} - #{@record.meta["as_of"].to_date.strftime("%B %d, %Y")}"
        }
      end
      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/repayment_rates/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]
      @subheader_side_actions << {
  id: "btn-print-rp",
  link: '#',
  class: "fa fa-print",
  text: "Print",
  data: {
    action: "print"
  }
}

      @payload = {
        id: @record.id,
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end
  end
end
