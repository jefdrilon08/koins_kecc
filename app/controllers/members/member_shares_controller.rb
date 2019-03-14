module Members
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!
    before_action :load_member!
      
    def new
      date_of_issued  = @member.membership_payment_records.paid.order("date_paid ASC").last.try(:date_paid)
      @member_share   = MemberShare.new(date_of_issued: date_of_issue)
    end

    def create
      @member_share         = MemberShare.new(member_share_params)
      @member_share.member  = @member

      @member_share.data  = {
        printed: false,
        date_printed: Date.today
      }

      if @member_share.save

        ActivityLog.create!(
          content: "#{current_user.full_name} created member_share #{@member_share.certificate_number} of #{@member.full_name}",
          activity_type: "create",
          data: {
            user_id: current_user.id,
            member_share: @member_share
          }
        )

        redirect_to member_member_share_path(@member, @member_share)
      else
        render :new
      end
    end

    def edit
      @member_share = MemberShare.find(params[:id])
    end

    def flag_as_printed
      @member_share = MemberShare.find(params[:member_share_id])
      @member_share.update!(data: { printed: true, date_printed: Date.today})

      redirect_to member_member_share_path(@member_share.member.id, @member_share.id)
    end

    def update
      @member_share         = MemberShare.find(params[:id])
      @member_share.member  = @member

      if @member_share.update(member_share_params)
        data  = @member_share.data.with_indifferent_access

        data[:printed] = false

        @member_share.update!(data: data)

        ActivityLog.create!(
          content: "#{current_user.full_name} updated member_share #{@member_share.certificate_number} of #{@member.full_name}",
          activity_type: "modification",
          data: {
            user_id: current_user.id,
            member_share: @member_share
          }
        )

        redirect_to member_member_share_path(@member, @member_share)
      else
        render :new
      end
    end

    def show
      @member_share = MemberShare.find(params[:id])
    end

    def destroy
      @member_share       = MemberShare.find(params[:id])
      certificate_number  = @member_share.certificate_number

      @member_share.destroy!

      ActivityLog.create!(
        content: "#{current_user.full_name} deleted member_share #{certificate_number} of #{@member.full_name}",
        activity_type: "delete",
        data: {
          user_id: current_user.id,
          certificate_number: certificate_number
        }
      )

      redirect_to member_path(@member_share.member)
    end

    private

    def load_member!
      @member = Member.find(params[:member_id])
    end

    def member_share_params
      params.require(:member_share).permit!
    end
  end
end
