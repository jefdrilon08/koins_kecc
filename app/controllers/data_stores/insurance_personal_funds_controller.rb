module DataStores
  class InsurancePersonalFundsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Insurance Personal Funds" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" },
        { text: "Generate for all branches", link: "#", class: "fa fa-plus", id: "btn-generate-all" }
      ]

      @payload = {
        urlQueue: "#{ENV['BACKEND_API_URL']}/api/v1/data_stores/insurance_personal_funds/queue",
        urlQueueBulk: "#{ENV['BACKEND_API_URL']}/api/v1/data_stores/insurance_personal_funds/queue_bulk",
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end

    def show
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Insurance Personal Funds", is_link: true, path:  "/data_stores/insurance_personal_funds" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.meta["branch_name"]} - #{@record.meta["as_of"].to_date.strftime("%B %d, %Y")} - #{@record.meta["member_status"].try(:upcase)}"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/insurance_personal_funds/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id,
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end
  end
end
