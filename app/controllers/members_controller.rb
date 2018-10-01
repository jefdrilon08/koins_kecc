class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @member = Member.find(params[:id])
  end
end
