class EquityAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @equity_account       = MemberAccount.equities.where(id: params[:id]).first
    @account_transactions = AccountTransaction.where(
                              subsidiary_id: @equity_account.id
                            ).order("transacted_at ASC, updated_at ASC")
  end
end
