module Accounting
  class AccountingEntriesController < ApplicationController
    before_action :authenticate_user!

    def show
      @accounting_entry = AccountingEntry.find(params[:id])
    end
  end
end
