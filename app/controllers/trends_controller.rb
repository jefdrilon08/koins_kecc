class TrendsController < ApplicationController
  before_action :authenticate_user!

  def index
    @subheader_items = [
      { text: "Trends" }
    ]

    @payload = {
      urlSync: "#{ENV['BACKEND_API_URL']}/api/v2/trends/fetch_yearly_data",
      userId: current_user.id,
      xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
    }
  end
end
