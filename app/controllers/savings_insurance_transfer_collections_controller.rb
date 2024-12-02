class SavingsInsuranceTransferCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @savings_insurance_transfer_collections = SavingsInsuranceTransferCollection.select("*").where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where(status: @status)
    end

    @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.order("status DESC, collection_date DESC").page(params[:page]).per(100)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Savings Insurance Transfers"
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
    @savings_insurance_transfer_collection  = SavingsInsuranceTransferCollection.find(params[:id])
    @savings_insurance_transfer_collection_data = @savings_insurance_transfer_collection.data.with_indifferent_access
    @insurance_subtype = @savings_insurance_transfer_collection_data[:insurance_subtype]

    # raise @insurance_subtype.inspect

    if @savings_insurance_transfer_collection.processing?
      redirect_to savings_insurance_transfer_collections_path
    end

    # if @savings_insurance_transfer_collection.branch_id != "3a74c7d5-54a5-4eec-826d-ab81f76ae31a" && @savings_insurance_transfer_collection.center_id != "5feb513d-6963-4b30-acdc-7630da3aef13" && @insurance_subtype != "Credit Life Insurance Plan"
      @accounting_entry_hash                  = @savings_insurance_transfer_collection.data.with_indifferent_access[:accounting_entry]
      @particular                             = @accounting_entry_hash[:particular]
    # end
    
    @members  = Member.active.where(
                  center_id: @savings_insurance_transfer_collection.center.id
                ).where.not(
                  id: @savings_insurance_transfer_collection.member_ids
                ).order("last_name ASC")

    if @savings_insurance_transfer_collection.clip
      @clip_data = @savings_insurance_transfer_collection.data.with_indifferent_access[:clip_data]
      
      if @clip_data.present?
        @loan_product_id = @clip_data[:loan_product_id]
        @principal = @clip_data[:principal]
        @term = @clip_data[:term]
        @num_installments = @clip_data[:num_installments]
        @maturity_date = @clip_data[:maturity_date]
        @effective_date = @clip_data[:effective_date]
        @clip_number = @clip_data[:clip_number]
        @beneficiary = @clip_data[:beneficiary]
      end
      @members  = Member.active.where(center_id: @savings_insurance_transfer_collection.center.id)
    end

    if @savings_insurance_transfer_collection.kbente
      @kbente_data = @savings_insurance_transfer_collection.data.with_indifferent_access[:kbente_data]
      
      if @kbente_data.present?
        @kbente_beneficiary_name = @kbente_data[:kbente_beneficiary_name]
        @date_of_birth = @kbente_data[:date_of_birth]
        @gender = @kbente_data[:gender]
        @status = @kbente_data[:status]
        @address = @kbente_data[:address]
        @effectivity_date = @kbente_data[:effectivity_date]
        @premium = @kbente_data[:premium]
        @relationship = @kbente_data[:relationship]
        @beneficiary_age = @kbente_data[:beneficiary_age]
        #@beneficiary_age[:beneficiary_age] = @beneficiary_age[:date_of_birth].present? ? Date.today.year - @data[:date_of_birth].to_date.year : ""
      end

      @members  = Member.active.where(center_id: @savings_insurance_transfer_collection.center.id)
    end
    
    if @savings_insurance_transfer_collection.kkalinga
      @kkalinga_data = @savings_insurance_transfer_collection.data.with_indifferent_access[:kkalinga_data]
      
      if @kkalinga_data.present?
        @kkalinga_name_of_insured = @kkalinga_data[:kkalinga_name_of_insured]
        @kkalinga_date_of_birth = @kkalinga_data[:kkalinga_date_of_birth]
        @kkalinga_gender = @kkalinga_data[:kkalinga_gender]
        @kkalinga_status = @kkalinga_data[:kkalinga_status]
        @kkalinga_address = @kkalinga_data[:kkalinga_address]
        @kkalinga_effectivity_date = @kkalinga_data[:effectivity_date]
        @kkalinga_premium = @kkalinga_data[:kkalinga_premium]
        @kkalinga_relationship = @kkalinga_data[:kkalinga_relationship]
        @kkalinga_beneficiary_name = @kkalinga_data[:kkalinga_beneficiary_name]
        @kkalinga_beneficiary_age = @kkalinga_data[:kkalinga_beneficiary_age]
        @beneficiary_age[:beneficiary_age] = @beneficiary_age[:date_of_birth].present? ? Date.today.year - @data[:date_of_birth].to_date.year : ""
      end

      @members  = Member.active.where(center_id: @savings_insurance_transfer_collection.center.id)
    end
    


    @records  = @savings_insurance_transfer_collection.data.with_indifferent_access["records"]

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: savings_insurance_transfer_collections_path,
        text: "Savings Insurance Transfers"
      },
      {
        text: "Record: #{@savings_insurance_transfer_collection.id}"
      }
    ]

    @subheader_side_actions = []

    if @savings_insurance_transfer_collection.pending?
      if ["MIS", "BK", "SBK"].include? current_user.roles.last
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }
      end

      @subheader_side_actions << {
        link: savings_insurance_transfer_collection_path(@savings_insurance_transfer_collection.id),
        class: "fa fa-times",
        text: "Delete",
        data: { method: :delete, confirm: "Are you sure?" }
      }
    end
    if @savings_insurance_transfer_collection.kbente 
      if @savings_insurance_transfer_collection.approved? or @savings_insurance_transfer_collection.pending?
        if ["MIS", "BK", "SBK"].include? current_user.roles.last
           @subheader_side_actions << {
            id: "btn-print",
            class: "fa fa-print",
            text: "Print",
            data: {
              id: "#{@savings_insurance_transfer_collection}"
                  }
          }
        end
      end
    end
    if @savings_insurance_transfer_collection.kkalinga
      if @savings_insurance_transfer_collection.approved? or @savings_insurance_transfer_collection.pending?
        if ["MIS", "BK", "SBK"].include? current_user.roles.last
           @subheader_side_actions << {
            id: "btn-print-k",
            class: "fa fa-print",
            text: "Print",
            data: {
              id: "#{@savings_insurance_transfer_collection}"
                  }
          }
        end
      end
    end
    @payload = {
      id: @savings_insurance_transfer_collection.id
    }
  end

  def destroy
    @savings_insurance_transfer_collection  = SavingsInsuranceTransferCollection.find(params[:id])
    @savings_insurance_transfer_collection.destroy!

    redirect_to savings_insurance_transfer_collections_path
  end
end