class UploadLoansController < ApplicationController
  before_action :authenticate_user!

  def index
    render 'loans/upload_loans/index', layout: "application"
  end
end