module Administration
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :load_user!, only: [:show, :edit, :update]

    def index
      @users  = User.select("*")
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to administration_user_path(@user)
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to administration_user_path(@user)
      else
        render :edit
      end
    end

    def show
    end

    private

    def load_user!
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit!
    end
  end
end
