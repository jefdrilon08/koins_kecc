class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:login]

  def index
  end

  def login
    render 'pages/login', layout: 'plain'
  end
end
