module DataStores
  class PersonalFundsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Personal Funds" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" }
      ]

      @payload = {
        urlQueue: "#{ENV['BACKEND_API_URL']}/api/v1/data_stores/personal_funds/queue",
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end

    def show
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Personal Funds", is_link: true, path:  "/data_stores/personal_funds" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.meta["branch_name"]} - #{@record.meta["as_of"].to_date.strftime("%B %d, %Y")}"
        }
      end

      @subheader_side_actions = []

      if is_mis_user?
      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/personal_funds/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]
      end

      @payload = {
        id: @record.id,
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end

    private

    def is_mis_user?
      current_user&.roles&.include?('MIS')
    end
  end
end
