module Administration
  class UserDemeritsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_user!
    before_action :load_object!, only: [:show, :edit, :update, :destroy]

    def index
      @user_demerits  = UserDemerit.where(user_id: @user.id)
    end

    def new
      @user_demerit = UserDemerit.new(date_of_action: Date.today, demerit_type: 'verbal', branch: @branches.first, role: @user.roles.last)
    end

    def create
      @user_demerit       = UserDemerit.new(user_demerit_params)
      @user_demerit.user  = @user
      
      @user_demerit.data  = {
        prepared_by: {
          id: current_user.id,
          first_name: current_user.first_name,
          last_name: current_user.last_name
        }
      }

      if @user_demerit.save
        redirect_to administration_user_user_demerit_path(@user, @user_demerit)
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @user_demerit.update(user_demerit_params)
        redirect_to administration_user_user_demerit_path(@user, @user_demerit)
      else
        render :edit
      end
    end

    def show
    end

    def destroy
      if !@user_demerit.pending?
        redirect_to administration_user_user_demerit_path(@user, @user_demerit)
      end

      @user_demerit.destroy!

      redirect_to administration_user_path(@user)
    end

    private

    def load_object!
      @user_demerit = UserDemerit.find(params[:id])
    end

    def user_demerit_params
      params.require(:user_demerit).permit!
    end

    def load_user!
      @user   = User.find(params[:user_id])
    end
  end
end
