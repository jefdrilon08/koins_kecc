class TransferSavingsController < ApplicationController
	  before_action :authenticate_user!

	  def index
	  	@records = TransferSavingsRecord.all
  	 @subheader_items = [
       {
         text: "Transfer Savings Records"
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

    def show
      @transfer_savings_record = TransferSavingsRecord.find(params[:id])
      @data_transfer = @transfer_savings_record.data.with_indifferent_access
      @accounting_entry = @data_transfer[:accounting_entry]

      if @transfer_savings_record.pending?
        @subheader_side_actions = [
          {
           id: "btn-approved",
           link: "#",
           class: "fa fa-plus",
           text: "Approved"
         }
       ]
      end

       @payload = {
        id: @transfer_savings_record.id
      }
    end
end
