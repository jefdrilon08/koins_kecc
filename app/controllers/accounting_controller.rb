class AccountingController < ApplicationController
  before_action :authenticate_user!

  def trial_balance
  end

  def general_ledger
  end

  def jvb
    @records  = AccountingEntry.jvb

    @records  = @records.page(params[:page]).per(20)
  end

  def crb
    @records  = AccountingEntry.crb

    @records  = @records.page(params[:page]).per(20)
  end

  def cdb
    @records  = AccountingEntry.cdb

    @records  = @records.page(params[:page]).per(20)
  end
end
