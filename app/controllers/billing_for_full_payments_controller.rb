class BillingForFullPaymentsController < ApplicationController
  def index
      @subheader_items = [
        {
          text: "Billing for Full Payment Loan"
        }
      ]
      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
  end
end
