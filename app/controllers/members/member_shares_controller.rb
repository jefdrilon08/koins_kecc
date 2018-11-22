module Members
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!
  end
end
