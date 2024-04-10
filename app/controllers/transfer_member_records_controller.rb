class TransferMemberRecordsController < ApplicationController
  before_action :authenticate_user!
	  
    def destroy
      @transfer_member_records = TransferMemberRecord.find(params[:id])
      if @transfer_member_records[:status] == "pending" 
         @transfer_member_records.destroy!
         redirect_to transfer_member_records_path
      else
          redirect_to transfer_member_records(@transfer_member_records)
      end
	  end

	  def index
      
      @records = TransferMemberRecord.all.order("updated_at DESC")


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

    def show
      @records = TransferMemberRecord.find(params[:id])
      @from_branch = Branch.find(@records[:branch_id])
      @to_branch= Branch.find(@records[:branch_id_to_transfer])
      @data_records = @records.data.with_indifferent_access
      @accounting_entry_from = @data_records[:accounting_entry_from]
      @accounting_entry_to = @data_records[:accounting_entry_to]
      @center_from = Center.where(branch_id: @records.branch_id).map{ |cnt|
        {
          id: cnt.id,
          name: cnt.name
        }
      }
 
        
      @particular_from = @accounting_entry_from[:particular] || "To Record Transfer Member/s From #{@from_branch.name} to #{@to_branch.name}"
      @particular_to = @accounting_entry_to[:particular] || "To Received Transfer Member/s From #{@from_branch.name}"
      if @records[:status] == "pending"
        @members = Member.active_and_resigned.where(branch_id: @records[:branch_id]).order("last_name ASC").map{ |o|
            {
              id: o.id,
              first_name: o.first_name,
              middle_name: o.middle_name,
              last_name: o.last_name,
              center: {
                id: o.center.id,
                name: o.center.name
              }
            }
          }

        @center = Center.where(branch_id: @records.branch_id_to_transfer).map{ |cnt|
        {
          id: cnt.id,
          name: cnt.name
        }
      }
      end
        @subheader_items = [
        { text: "Transfer Member From #{@from_branch.name} To #{@to_branch.name}" },
        { text: "Transfer Member Record", is_link: true, path: "/transfer_member_records" }
      ]


    @subheader_side_actions = []
      if @records.status == "pending"
        if helpers.sbk_mis_user
            @subheader_side_actions << {
              id: "btn-approve",
              link: "#",
              class: "fa fa-check",
              text: "Approve"
            }
        end
         @subheader_side_actions << {
          id: "",
          link: "/transfer_member_records/#{@records.id}",
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }
      end
        @payload = {
        id: @records.id
      }
    end

   
	end
