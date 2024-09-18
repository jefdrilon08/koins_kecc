class MembershipPaymentCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @membership_payment_collections = MembershipPaymentCollection
      .select("id,status,si_number,center_id,branch_id,status,date_approved,or_number,ar_number,total_collected,collection_date")
      .includes(:branch, :center)
      .where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @membership_payment_collections = @membership_payment_collections.where("collection_date >= ?  and collection_date <= ?", params[:start_date], params[:end_date] )
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @membership_payment_collections = @membership_payment_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center = Center.find(params[:center_id])
    
      @membership_payment_collections = @membership_payment_collections.where(center_id: @center.id)

    end

    if params[:status].present?
      @status = params[:status]
      @membership_payment_collections = @membership_payment_collections.where(status: @status)
    end

    @membership_payment_collections = @membership_payment_collections.order("status DESC, collection_date DESC").page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Membership Payments"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new-transaction",
        link: "#",
        class: "fa fa-plus",
        text: "New Transaction"
      }
    ]
  end

  def show
    @membership_payment_collection  = MembershipPaymentCollection.find(params[:id])

    if @membership_payment_collection.processing?
      redirect_to membership_payment_collections_path
    else
      @data     = @membership_payment_collection.data.with_indifferent_access

      @activity_logs  = ActivityLog.where(
                          "data ->> 'membership_payment_collection_id' = ?",
                          @membership_payment_collection.id
                        ).order("created_at DESC")
    end

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: membership_payment_collections_path,
        text: "Membership Payments"
      },
      {
        text: "Membership Payment: #{@membership_payment_collection.id}"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-print",
        link: "#",
        class: "fa fa-print",
        text: "Print"
      }
    ]

    if @membership_payment_collection.pending? && helpers.sbk_mis_bk_oas? && current_user.roles.any?
      @subheader_side_actions << {
        link: membership_payment_collection_path(@membership_payment_collection),
        class: "fa fa-times",
        data: { confirm: "Are you sure?", method: :delete },
        text: "Delete"
      }
    end

    if helpers.sbk_bk_mis_user && current_user.roles.any?
      @subheader_side_actions << {
        link: "#",
        class: "fa fa-check",
        id: "btn-approve",
        text: "Approve"
      }
      @subheader_side_actions << {
        link: "#",
        class: "fa fa-print-thermal",
        id: "btn-thermal",
        text: "Print Thermal"
      }
      
    end

    @payload = {
      id: @membership_payment_collection.id
    }
  end

  def destroy
    @membership_payment_collection  = MembershipPaymentCollection.find(params[:id])

    if @membership_payment_collection.pending?
      @membership_payment_collection.destroy!

      redirect_to membership_payment_collections_path
    else
      redirect_to membership_payment_collection_path(@membership_payment_collection)
    end
  end
end
