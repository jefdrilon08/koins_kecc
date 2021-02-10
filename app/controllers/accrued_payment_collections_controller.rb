class AccruedPaymentCollectionsController < ApplicationController
	def index
		@sample = ""

		@subheader_items = [
        {
          text: "Accrued Interest Payment Collection"
        }
      ]
      @subheader_side_actions = [
      	{ id: "btn-new-transaction", link: "#", class: "fa fa-plus", text: "New Transaction" }
      ]
	end
  def show
    @accrued_interest_collection  = AccruedBilling.find(params[:id])
  end
end