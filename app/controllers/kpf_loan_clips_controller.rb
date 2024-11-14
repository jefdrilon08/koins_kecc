class KpfLoanClipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @kpf_loan_clips = KpfLoanClip.select("*").where(branch_id: @branches.pluck(:id))
    @center   = Center.where(id: params[:center_id]).first
    @q        = params[:q]
    @branch   = Branch.where(id: params[:branch_id]).first

    if @q.present?
      @kpf_loan_clips = @kpf_loan_clips.where(
        "upper(data->'records'->0->'member'->>'first_name') LIKE :q OR upper(data->'records'->0->'member'->>'last_name') LIKE :q",
        q: "%#{@q.upcase}%"
      )
    end

    if @branch.present?
      @kpf_loan_clips  = @kpf_loan_clips.where(branch_id: @branch.id)
    end

    if params[:start_date].present? and params[:end_date].present?
      @kpf_loan_clips = @kpf_loan_clips.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @kpf_loan_clips = @kpf_loan_clips.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @kpf_loan_clips = @kpf_loan_clips.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @kpf_loan_clips = @kpf_loan_clips.where(status: @status)
    end

    @kpf_loan_clips = @kpf_loan_clips.order("status DESC, collection_date DESC").page(params[:page]).per(100)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Kpf Loan Clips"
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
    @kpf_loan_clip  = KpfLoanClip.find(params[:id])

    if @kpf_loan_clip.processing?
      redirect_to kpf_loan_clips_path
    end

    @members  = Member.active.where(
                  center_id: @kpf_loan_clip.center.id
                ).where.not(
                  id: @kpf_loan_clip.member_ids
                ).order("last_name ASC")

    @clip_data = @kpf_loan_clip.data.with_indifferent_access[:clip_data]

    if @clip_data.present?
      @effectivity_date   = @clip_data[:effectivity_date]
      @maturity_date      = @clip_data[:maturity_date]
      @amount             = @clip_data[:amount]
      @clip_number        = @clip_data[:clip_number]
      @beneficiary        = @clip_data[:beneficiary]
      @loan_product_id    = @clip_data[:loan_product_id]
      @num_installments   = @clip_data[:benif_lname]
    end

    @members  = Member.active.where(center_id: @kpf_loan_clip.center.id)
    @records  = @kpf_loan_clip.data.with_indifferent_access["records"]

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: kpf_loan_clips_path,
        text: "Kpf Loan Clips"
      },
      {
        text: "Record: #{@kpf_loan_clip.id}"
      }
    ]

    @subheader_side_actions = []

    if @kpf_loan_clip.pending?
      if ["OAS", "MIS", "REMOTE-MIS"].include? current_user.roles.last
        @subheader_side_actions << {
          id: "btn-print",
          class: "fa fa-print",
          text: "Print PDF",
          data: {
            id: "#{@kpf_loan_clip}"
          }
        }

        if @kpf_loan_clip.records_count > 0
            @subheader_side_actions << {
            id: "btn-check",
            link: "#",
            class: "fa fa-check",
            text: "For-Checking"
          }
        end

        @subheader_side_actions << {
              id: "btn-declined",
              link: "#",
              class: "fa fa-check",
              text: "Decline"
        }

        @subheader_side_actions << {
          link: kpf_loan_clip_path(@kpf_loan_clip.id),
          class: "fa fa-times",
          text: "Delete",
          data: { method: :delete, confirm: "Are you sure?" }
        }
      end
    end

    if @kpf_loan_clip.checked?
      if ["MIS", "FM", "CM", "REMOTE-MIS"].include? current_user.roles.last
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }
        @subheader_side_actions << {
            id: "btn-declined",
            link: "#",
            class: "fa fa-check",
            text: "Decline"
        }
      end
    end


    @payload = {
      id: @kpf_loan_clip.id
    }
  end

  def destroy
    @kpf_loan_clip  = KpfLoanClip.find(params[:id])
    @kpf_loan_clip.destroy!

    redirect_to kpf_loan_clips_path
  end


end
