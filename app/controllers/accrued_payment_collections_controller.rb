class AccruedPaymentCollectionsController < ApplicationController
	def index
		@subheader_items = [
        {
          text: "Accrued Interest Payment Collection"
        }
      ]
      @subheader_side_actions = [
      	{ id: "btn-new-transaction", link: "#", class: "fa fa-plus", text: "New Transaction" }
      ]

    @accrued_interest = AccruedBilling.where(branch_id: @branches.pluck(:id))

	end

  def show
    @subheader_side_actions = [
        {
          id: "btn-printpdf",
          link: "/print?type=accrued_billing&id=#{params[:id]}",
          class: "fa fa-print",
          text: "PDF"
        }
      ]        
    @accrued_interest_collection  = AccruedBilling.find(params[:id])
    @accrued_member = @accrued_interest_collection.data['member_data']
    
  end
end