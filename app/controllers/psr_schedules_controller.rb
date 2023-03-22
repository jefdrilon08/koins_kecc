class PsrSchedulesController < ApplicationController
  before_action :authenticate_user!

  def generate
    @payload = {
      branches: @branches.map{ |o| o.to_h },
      branch_options: @branches.map{ |o| { value: o.id, label: o.name } },
      token: current_user.generate_jwt
    }
  end
end
