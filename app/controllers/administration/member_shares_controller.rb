module Administration
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!

    def index
      @member_shares  = MemberShare.not_printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id))

      if params[:branch_id].present?
        @branch_id  = params[:branch_id]
        @branch     = Branch.find(@branch_id)

        @member_shares  = @member_shares.where("members.branch_id = ?", @branch.id)
      end

      @member_shares  = @member_shares.page(params[:page]).per(20)
    end
  end
end
