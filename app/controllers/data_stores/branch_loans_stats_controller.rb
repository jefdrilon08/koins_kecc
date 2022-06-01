module DataStores
  class BranchLoansStatsController < DataStoreController
    def index
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Loan Stats" }
      ]

      @subheader_side_actions = [
      ]
    end

    def show
      super

      @subheader_items = [
        { text: "Data Stores" },
        { text: "Loan Stats", is_link: true, path:  "/data_stores/branch_loans_stats" }
      ]

      if !@record.error?
        @subheader_items << {
          text: "#{@record.data["branch"].fetch("name")} - #{@record.data["as_of"].try(:to_date).try(:strftime, "%B %d, %Y")}"
        }
      end

      @subheader_side_actions = [
        { text: "Delete", class: "fa fa-times", link: "/data_stores/branch_loans_stats/#{@record.id}", data: { method: :delete, confirm: "Are you sure?" } }
      ]

      @payload = {
        id: @record.id
      }
    end

    private

    def data_store_scope
      "repayment_rates" # There's no .branch_loan_stats scope
    end
  end
end
