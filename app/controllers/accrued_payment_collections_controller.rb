class AccruedPaymentCollectionsController < ApplicationController
  before_action :authenticate_user!

	def index

		@subheader_items = [
        {
          text: "Accrued Interest Payment Collection"
        }
      ]
      @subheader_side_actions = [
      	{ id: "btn-new-transaction", link: "#", class: "fa fa-plus", text: "New Transaction" }
      ]

      @accrued_interest = AccruedBilling.where(branch_id: @branches.pluck(:id)).order("status DESC , collection_date DESC")
    # #   if params[:status].present?
    # #     @accrued_interest = AccruedBilling.where(status: params[:status]).order("status DESC , collection_date DESC")
      
    # #   elsif params[:branch_select].present?
    # #     @accrued_interest = AccruedBilling.where(branch_id: params[:branch_select]).order("status DESC , collection_date DESC")
      
    # #   elsif params[:center_select].present?
    # #     @accrued_interest = AccruedBilling.where(center_id: params[:center_select]).order("status DESC , collection_date DESC")

    # # if params[:status].present?
    # #   @status = params[:status]
    # #   @accrued_interest = @accrued_interest.where(status: @status)
    # # end

    #   end

    if params[:branch_select].present?
      @branch   = ReadOnlyBranch.find(params[:branch_select])
      @accrued_interest = @accrued_interest.where(branch_id: @branch.id)
    end

    if params[:center_select].present?
      @center   = ReadOnlyCenter.find(params[:center_select])
      @accrued_interest = @accrued_interest.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @accrued_interest = @accrued_interest.where(status: @status)
    end

    @accrued_interest = @accrued_interest.order("status DESC, collection_date DESC").page(params[:page]).per(20)

	end

  def show 
    @accrued_interest_collection  = AccruedBilling.find(params[:id])

    record = ::AccruedPaymentCollections::BuildAccountingEntry.new(
      accrued_billing: @accrued_interest_collection,
      current_user: current_user
    ).execute!
 

    @data = @accrued_interest_collection.data.with_indifferent_access
    @accounting_entry = @data[:accounting_entry]
    @accrued_member = @accrued_interest_collection.data['member_data']

    @subheader_items = [
      { is_link: true, path: accrued_payment_collections_path, text: "Accrued Payment Collections"},
      { text: "#{@accrued_interest_collection.id}" }

    ]    
    @subheader_side_actions = []
      if @accrued_interest_collection.status == 'pending'
        @subheader_side_actions << {
          id: "btn-delete",
          link: "#",
          class: "fa fa-times",
          data: {id: @accrued_interest_collection.id},
          text: "Delete"
        }
       if helpers.oas_mis_user
          @subheader_side_actions << {
            id: "btn-zero",
            link: "#",
            class: "fa fa-times",
            data: {id: @accrued_interest_collection.id},
            text: "Zero Out"
          }
        end
        if helpers.sbk_bk_mis_user
          @subheader_side_actions << {
            id: "btn-approve",
            link: "#",
            class: "fa fa-check",
            data: {id: @accrued_interest_collection.id},
            text: "Approve"
          }
        end
      end
      @subheader_side_actions << {
          id: "btn-printpdf",
          link: "/print?type=accrued_billing&id=#{params[:id]}",
          class: "fa fa-print",
          text: "Print"
        }

  end
end
