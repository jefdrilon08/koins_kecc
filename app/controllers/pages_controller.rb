class PagesController < ApplicationController
  def index
  end

  def login
    render 'pages/login', layout: 'plain'
  end
end
