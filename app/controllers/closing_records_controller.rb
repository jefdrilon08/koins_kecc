class ClosingRecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    branches = @branches.map{ |o|
      {
        id: o.id,
        name: o.name
      }
    }

    @payload = {
      branches: branches,
      token:    current_user.generate_jwt
    }
  end
end
