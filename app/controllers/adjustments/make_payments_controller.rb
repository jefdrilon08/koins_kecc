module Adjustments
  class MakePaymentsController < ApplicationController
    def index
      @make_payment = MakePayment.all
    end
    def show
      @make_payment_details = MakePayment.find(params[:id])
      @accounting_entry = ::Adjustments::MakePayments:: BuildAccountingEntryForMakePayments.new(make_payment_data: @make_payment_details, current_user: current_user   ).execute!
      #raise @make_payment_details.member_id.inspect
    @subheader_items = [
      { is_link: true, path: member_path(@make_payment_details.member_id), text: "Make Payment" },
      { is_link: true, path: member_path(@make_payment_details.member_id), text: "#{Member.find(@make_payment_details.member_id).full_name}" }
    ]
    @subheader_side_actions = [
      {
        id: "btn-approve",
        link: "#",
        class: "fa fa-check",
        text: "Approve",
      
        data: { member_id: @make_payment_details.member_id }
      },
      { 
        is_link: true, 
        path: member_path(@make_payment_details.member_id), 
        class: "fa fa-times",
        text: "Cancel" }
    ]
      
    end
  end
end
