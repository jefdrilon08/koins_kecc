class AccountingController < ApplicationController
  before_action :authenticate_user!

  def trial_balance
  end

  def general_ledger
  end

  def jvb
    @records  = AccountingEntry.jvb.order("reference_number DESC")

    @records  = @records.page(params[:page]).per(20)
  end

  def crb
    @records  = AccountingEntry.crb.order("reference_number DESC")

    @records  = @records.page(params[:page]).per(20)
  end

  def cdb
    @records  = AccountingEntry.cdb.order("reference_number DESC")

    @records  = @records.page(params[:page]).per(20)
  end

  def form
  end
end
