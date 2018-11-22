module Members
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!
    before_action :load_member!
      
    def new
      @member_share = MemberShare.new
    end

    def create
      @member_share         = MemberShare.new(member_share_params)
      @member_share.member  = @member

      if @member_share.save
        redirect_to member_member_share_path(@member, @member_share)
      else
        render :new
      end
    end

    def edit
      @member_share = MemberShare.find(params[:id])
    end

    def update
      @member_share         = MemberShare.find(params[:id])
      @member_share.member  = @member

      if @member_share.update(member_share_params)
        redirect_to member_member_share_path(@member, @member_share)
      else
        render :new
      end
    end

    def show
      @member_share = MemberShare.find(params[:id])
    end

    def destroy
      @member_share = MemberShare.find(params[:id])
      @member_share.destroy!
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
