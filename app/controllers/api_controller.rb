class ApiController < ApplicationController
  def authenticate_app_request! 
    if request.headers["X-KOINS-APP-AUTH-SECRET"].blank?
      render json: { message: "unauthenticated" }, status: 400
    elsif request.headers["X-KOINS-APP-AUTH-SECRET"] != app_auth_secret
      render json: { message: "invalid auth token" }, status: 400
    end
  end

  def app_auth_secret
    ENV['KOINS_APP_AUTH_SECRET']
  end
end
