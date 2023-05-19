module DataStores
  class MemberQuarterlyReportsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Member Quarterly Reports" }
      ]

      @subheader_side_actions = [
        { text: "New", link: "#", class: "fa fa-plus", id: "btn-new" }
      ]
    end

    def show
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Member Quarterly Reports", is_link: true, path:  "/data_stores/member_quarterly_reports" }
      ]

      if !@record.error?
        @subheader_items << {
          # text: "#{@record.data["branch"]["name"]} - #{@record.data["as_of"].to_date.strftime("%B %d, %Y")}"
          # text: "#{@record.data["as_of"].to_date.strftime("%B %d, %Y")}"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/member_quarterly_reports/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id
      }
    end
  end
end
