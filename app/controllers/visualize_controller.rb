class VisualizeController < ApplicationController
  before_action :authenticate_user!

  def monthly_psr
    @payload = {
      branches:     @branches.map{ |o| o.to_h },
      token:        current_user.generate_jwt,
      current_year: Date.today.year
    }
  end
end
