module Adjustments
  class MakePaymentsController < ApplicationController
    def index
      make_payment_type = params[:make_payment_type]
      if params[:make_payment_type].present? || params[:status].present?
        status_downcase = params[:status].downcase
        @make_payment = MakePayment.joins(:member).where("members.branch_id in (?) and make_payments.make_payment_type = ? OR make_payments.status = ?", @branches.pluck(:id), make_payment_type, status_downcase)

      else
        
        @make_payment = MakePayment.joins(:member).where("members.branch_id in (?) ", @branches.pluck(:id))
      
      end
       
      @subheader_items = [
        {
    
          text: "Make Payment"
      
    
        }
      ]
    end
    def show
      @make_payment_details = MakePayment.find(params[:id])
      @accounting_entry = ::Adjustments::MakePayments:: BuildAccountingEntryForMakePayments.new(make_payment_data: @make_payment_details, current_user: current_user   ).execute!
      if @make_payment_details.status == "approve"
        @accounting_entry_details = AccountingEntry.find(@make_payment_details[:meta]["accounting_entry_id"])
      end
      #raise @make_payment_details.member_id.inspect
    @subheader_items = [
      { is_link: true, path: member_path(@make_payment_details.member_id), text: "Make Payment" },
      { is_link: true, path: member_path(@make_payment_details.member_id), text: "#{Member.find(@make_payment_details.member_id).full_name}" }
    ]


    if @make_payment_details.status == "pending"
      @subheader_side_actions = [
        {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve",
      
          data: { make_payment_id: @make_payment_details.id }
        },
        {
          id: "btn-destroy",
          link: "#",
          class: "fa fa-check",
          text: "Destroy",
      
          data: { make_payment_id: @make_payment_details.id }
        }
      ]
    end
      
    end
  end
end
