module DataStores
  class SoaLoansController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Statement of Assets Loan Payments" }
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
        { text: "Statement of Assets Loan Payments", is_link: true, path:  "/data_stores/soa_loans" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "SOA Loan Payments dating #{@meta[:start_date].to_date.strftime("%B %d, %Y")} to #{@meta[:end_date].to_date.strftime("%B %d, %Y")}"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/soa_loans/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id
      }
    end
  end
end
