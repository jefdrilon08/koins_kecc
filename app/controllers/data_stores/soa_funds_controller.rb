module DataStores
  class SoaFundsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Statement of Accounts Funds" }
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
        { text: "Statement of Accounts Funds", is_link: true, path:  "/data_stores/soa_funds" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.data.with_indifferent_access[:branch][:name]} - #{@record.meta.with_indifferent_access[:start_date].to_date.strftime("%B %d, %Y")} to #{@record.meta.with_indifferent_access[:end_date].to_date.strftime("%B %d, %Y")}"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/soa_funds/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @subheader_side_actions << {
  id: "print_soaf",
  link: '#',
  class: "fa fa-print",
  text: "Print PDF",
  data: {
    action: "print"
  }
}

@subheader_side_actions << {
  id: "excel_soaf",
  link: '#',
  class: "fa fa-print",
  text: "Download Excel",
  data: {
    action: "print-excel"
    
  }
}


      @payload = {
        id: @record.id
      }
    end
  end
end
