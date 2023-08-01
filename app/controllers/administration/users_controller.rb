module Administration
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :load_user!, only: [:show, :edit, :update]

    def index
      @subheader_side_actions = [
        {
          id: "btn-new",
          link: new_administration_user_path,
          class: "fa fa-plus",
          text: "New User"
        }
      ]

      render 'pages/react_root'
    end

    def new
      @payload = {
        roles: User::ROLES
      }

      render 'pages/react_root'
    end

    def edit
      @payload = {
        roles: User::ROLES,
        id: params[:id]
      }

      render 'pages/react_root'
    end

    def update
      if @user.update(user_params)
        redirect_to administration_user_path(@user)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_users_path,
            text: "Users"
          },
          {
            text: "Edit User: #{@user.id}"
          }
        ]

        @subheader_side_actions = []

        render :edit
      end
    end

    def show
      @payload = {
        id: @user.id
      }

      render 'pages/react_root'
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
