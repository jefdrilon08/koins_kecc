module DataStores
  class SoaExpensesController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Statement of Assets Loan Expenses" }
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
        { text: "Statement of Assets Loan Expenses", is_link: true, path:  "/data_stores/soa_expenses" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "SOA Expenses dating #{@meta[:start_date].to_date.strftime("%B %d, %Y")} to #{@meta[:end_date].to_date.strftime("%B %d, %Y")} "
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/soa_expenses/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @subheader_side_actions << {
  id: "btn-print-soax",
  link: '#',
  class: "fa fa-print",
  text: "Print PDF",
  data: {
    action: "print"
  }
}

@subheader_side_actions << {
  id: "btn-print-excelsoax",
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
