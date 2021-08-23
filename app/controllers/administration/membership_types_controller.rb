module Administration
  class MembershipTypesController < ApplicationController
    before_action :authenticate_user!

    def index
      @membership_types  = MembershipType.select("*")

      if params[:name].present?
        @membership_types = @membership_types.where(
                    "upper(name) LIKE ?",
                     "%#{params[:name].upcase}%"
                  )
      end

      @membership_types  = @membership_types.order("name ASC").page(params[:page]).per(LIST_PAGE_SIZE)

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          text: "Membership Types"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: new_administration_membership_type_path,
          class: "fa fa-plus",
          text: "New Membership Type"
        }
      ]
    end

    def new
      @membership_type = MembershipType.new

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_membership_types_path,
          text: "Membership Types"
        },
        {
          text: "New"
        }
      ]
    end

    def create
      @membership_type = MembershipType.new(membership_type_params)

      if @membership_type.save
        redirect_to administration_membership_type_path(@membership_type)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_membership_types_path,
            text: "MembershipTypes"
          },
          {
            text: "New"
          }
        ]

        render :new
      end
    end

    def edit
      @membership_type = MembershipType.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_membership_types_path,
          text: "MembershipTypes"
        },
        {
          text: "Edit #{@membership_type.name}"
        }
      ]
    end

    def update
      @membership_type = MembershipType.find(params[:id])

      if @membership_type.update(membership_type_params)
        redirect_to administration_membership_type_path(@membership_type)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_membership_types_path,
            text: "MembershipTypes"
          },
          {
            text: "Edit #{@membership_type.name}"
          }
        ]

        render :edit
      end
    end

    def show
      @membership_type = MembershipType.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_membership_types_path,
          text: "MembershipTypes"
        },
        {
          text: "#{@membership_type.name}"
        }
      ]

      @subheader_side_actions = [
        {
          link: edit_administration_membership_type_path(@membership_type),
          class: "fa fa-pencil-alt",
          text: "Edit"
        },
         {
          link: administration_membership_type_path(@membership_type),
          class: "fa fa-times",
          data: { method: :delete, confirm: "Are you sure?" },
          text: "Delete"
        }
      ]

      @payload = {
        id: @membership_type.id
      }
    end

    def destroy
      @membership_type = MembershipType.find(params[:id])
      @membership_type.destroy!
      flash[:success] = "Successfully removed membership_type"
      redirect_to administration_membership_types_path
    end

    private

    def load_user!
      @membership_type = MembershipType.find(params[:id])
    end

    def membership_type_params
      params.require(:membership_type).permit!
    end
  end
end
