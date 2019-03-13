module Administration
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!

    def index
      @member_shares  = MemberShare.not_printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id))
      @members        = Member.active.where.not(id: MemberShare.all.pluck(:member_id).uniq).where(branch_id: @branches.pluck(:id)).order("last_name ASC")

      if params[:branch_id].present?
        @branch_id  = params[:branch_id]
        @branch     = Branch.find(@branch_id)

        @member_shares  = @member_shares.where("members.branch_id = ?", @branch.id)
        @members        = @members.where(branch_id: @branch.id)
      end

      @member_shares  = @member_shares.page(params[:page]).per(20)
    end

    def no_certificates
      @members        = Member.active.where.not(id: MemberShare.all.pluck(:member_id).uniq).where(branch_id: @branches.pluck(:id)).order("last_name ASC")

      @members  = @members.page(params[:page]).per(20)
    end

    def not_printed
      @member_shares  = MemberShare.not_printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id)).order("date_of_issue DESC")
      @member_shares  = @member_shares.page(params[:page]).per(20)
    end

    def printed
      @member_shares  = MemberShare.printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id)).order("date_of_issue DESC")
      @member_shares  = @member_shares.page(params[:page]).per(20)
    end
  end
end
