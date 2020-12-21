class AccruedPaymentCollectionsController < ApplicationController
	def index
		@sample = "Hello World"

		@subheader_items = [
        {
          text: "Accrued Interest Payment Collection"
        }
      ]
      @subheader_side_actions = [
      	{ id: "btn-new-transaction", link: "#", class: "fa fa-plus", text: "New Transaction" }
      ]
	end
end