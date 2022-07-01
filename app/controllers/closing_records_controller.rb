class ClosingRecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    branches = @branches.map{ |o|
      {
        id: o.id,
        name: o.name,
        current_date: o.current_date.try(:strftime, "%b %d %Y") || Date.today.strftime("%b %d %Y")
      }
    }

    @payload = {
      branches: branches,
      token:    current_user.generate_jwt
    }
  end
end
