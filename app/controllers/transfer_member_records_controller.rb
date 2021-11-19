class TransferMemberRecordsController < ApplicationController
	  
    def destroy
	  end

	  def index
      @subheader_items = [
        {
          text: "Data Store"
        },
        {
          text: "Transfer Member"
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