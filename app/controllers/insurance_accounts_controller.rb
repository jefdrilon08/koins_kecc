class InsuranceAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @insurance_account  = MemberAccount.insurance.where(id: params[:id]).first

    @account_transactions = AccountTransaction.where(
                              subsidiary_id: @insurance_account.id
                            ).order("transacted_at ASC, updated_at ASC")
  end
end
