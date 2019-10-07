class EquityAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @equity_accounts  = MemberAccount.equities

    if params[:q].present?
      @q  = params[:q]

      @equity_accounts = @equity_accounts.joins(:member).where(
                            "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(identification_number) LIKE :q",
                            q: "%#{@q.upcase}%"
                          )
    end

    if params[:subtype].present?
      @subtype  = params[:subtype]

      @equity_accounts = @equity_accounts.where(account_subtype: @subtype)
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @equity_accounts = @equity_accounts.where(branch_id: @branch.id)
    end

    @equity_accounts = @equity_accounts.page(params[:page]).per(20)
  end

  def show
    @equity_account       = MemberAccount.equities.where(id: params[:id]).first
    @account_transactions = AccountTransaction.where(
                              subsidiary_id: @equity_account.id
                            ).order("transacted_at ASC, updated_at ASC")
  end
end
