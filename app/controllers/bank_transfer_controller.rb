class BankTransferController < ApplicationController
    before_action :authenticate_user!

 def index
    @bank = BankTransfer.all

    @accounting_code    = AccountingCode.where(category:'LIABILITIES')
    @transferoption     = TransferOption.all
    
    @subheader_side_actions = [
    { id: "btn-new", 
      link: "#", 
      class: "fa fa-plus", 
      text: "Create Bank & Ewallet" },
      { 
      id: "btn-channel",
      link:"#",
      class:'fa fa-plus',
      text: "Create Channel" }
    ]
 end

    def edit
      @bank = BankTransfer.find(params[:id])
      @subheader_items = [
      {
         text: "sample"

      },
      {
         is_link: true,
         path: bank_transfer_path,
         text: "sample 1"
      },
      {
         text: "Edit: #{@bank.name}" 
      }
   ]

      @subheader_side_actions = []
    end

    def show
    end



end
