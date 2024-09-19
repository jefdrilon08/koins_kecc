class ApiReceiveMembersController < ApplicationController
  def index
    @api_receive_members = ApiReceiveMember.select("*").where(branch_id: @branches.pluck(:id))

    @branch   = Branch.where(id: params[:branch_id]).first

    if @branch.present?
      @api_receive_members  = @api_receive_members.where(branch_id: @branch.id)
    end

    if params[:start_date].present? and params[:end_date].present?
      @api_receive_members = @api_receive_members.where("receive_date >= ? AND receive_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @api_receive_members = @api_receive_members.where(branch_id: @branch.id)
    end

    if params[:status].present?
      @status = params[:status]
      @api_receive_members = @api_receive_members.where(status: @status)
    end

    @api_receive_members = @api_receive_members.order("status DESC, receive_date DESC").page(params[:page]).per(100)
  end

  def show
    @api_receive_members  = ApiReceiveMember.find(params[:id])
    @data = @api_receive_members.data
    @branch = @api_receive_members[:branch_id]
    @branch_name = ApiReceiveMember.select("*").where(branch_id: @branches.pluck(:id))


    @subheader_side_actions = []

    if @api_receive_members.pending?
      if ["OA", "MIS", "REMOTE-MIS"].include? current_user.roles.last
        # @subheader_side_actions << {
        #   id: "btn-print",
        #   class: "fa fa-print",
        #   text: "Print PDF",
        #   data: {
        #     id: "#{@api_receive_members}"
        #   }
        # }

        if @api_receive_members.pending?
          @subheader_side_actions << {
            id: "btn-approve",
            link: "#",
            class: "fa fa-check",
            text: "Approve"
          }

          # @subheader_side_actions << {
          #       id: "btn-declined",
          #       link: "#",
          #       class: "fa fa-check",
          #       text: "Decline"
          # }

          @subheader_side_actions << {
            link: api_receive_member_path(@api_receive_members.id),
            class: "fa fa-times",
            text: "Delete",
            data: { method: :delete, confirm: "Are you sure?" }
          }
        end
      end
    end

    # @api_receive_members.data.each do |member|
    #   if member["identification_number"].present?
    #     member_record = Member.find_by(identification_number: member["identification_number"])
    #     member["member_id"] = member_record&.id
    #   end
    # end

    @payload = {
      id: @api_receive_members.id
    }
  end

  def destroy
    @api_receive_member  = ApiReceiveMember.find(params[:id])
    @api_receive_member.destroy!

    redirect_to api_receive_members_path
  end
end
