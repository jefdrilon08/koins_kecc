class SavingsAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @savings_account  = MemberAccount.savings.where(id: params[:id]).first

    @account_transactions = AccountTransaction.where(
                              subsidiary_id: @savings_account.id
                            ).order("transacted_at ASC")
  end
end
