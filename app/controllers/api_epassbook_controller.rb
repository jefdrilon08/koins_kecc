class ApiEpassbookController < ApplicationController
  def authenticate_member_access_token!
    @access_token  = params[:access_token]

    if @access_token.blank?
      render json: { message: "invalid access" }, status: 400
    end
  end
end
