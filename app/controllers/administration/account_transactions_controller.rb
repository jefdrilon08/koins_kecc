module Administration
  class AccountTransactionsController < ApplicationController
    before_action :authenticate_user!

    def show
      @account_transaction  = AccountTransaction.find(params[:id])
    end
  end
end
