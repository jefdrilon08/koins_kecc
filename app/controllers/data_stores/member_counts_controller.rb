module DataStores
  class MemberCountsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Member Counts" }
      ]

      @subheader_side_actions = [
      ]

      @payload = {
        urlQueue: "#{ENV['BACKEND_API_URL']}/api/v1/data_stores/member_counts/queue",
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end

    def show
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Member Counts", is_link: true, path:  "/data_stores/member_counts" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.meta["branch_name"]} - #{@record.meta["as_of"].to_date.strftime("%B %d, %Y")}"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/member_counts/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id
      }
    end
  end
end
