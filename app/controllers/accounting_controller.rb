class AccountingController < ApplicationController
  before_action :authenticate_user!

  def trial_balance
  end
end
