module Administration
  class CentersController < ApplicationController
    before_action :authenticate_user!

    def index
      @centers  = Center.select("*").includes(:branch, :user).where(branch_id: @branches.pluck(:id))

      @centers  = @centers.order("name ASC").page(params[:page]).per(LIST_PAGE_SIZE)

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          text: "Centers"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: new_administration_center_path,
          class: "fa fa-plus",
          text: "New Center"
        }
      ]
    end

    def new
      @center = Center.new

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_centers_path,
          text: "Centers"
        },
        {
          text: "New"
        }
      ]
    end

    def create
      @center = Center.new(center_params)

      if @center.save
        redirect_to administration_center_path(@center)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_centers_path,
            text: "Centers"
          },
          {
            text: "New"
          }
        ]

        render :new
      end
    end

    def edit
      @center = Center.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_centers_path,
          text: "Centers"
        },
        {
          text: "Edit #{@center.name}"
        }
      ]
    end

    def update
      @center = Center.find(params[:id])

      if @center.update(center_params)
        redirect_to administration_center_path(@center)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_centers_path,
            text: "Centers"
          },
          {
            text: "Edit #{@center.name}"
          }
        ]

        render :edit
      end
    end

    def show
      @center = Center.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_centers_path,
          text: "Centers"
        },
        {
          text: "#{@center.name}"
        }
      ]

      @subheader_side_actions = [
        {
          link: edit_administration_center_path(@center),
          class: "fa fa-pencil-alt",
          text: "Edit"
        }
      ]

      @payload = {
        id: @center.id
      }
    end

    def destroy
      @center = Center.find(params[:id])
      @center.destroy!
      flash[:success] = "Successfully removed center"
      redirect_to administration_centers_path
    end

    private

    def load_user!
      @center = Center.find(params[:id])
    end

    def center_params
      params.require(:center).permit!
    end
  end
end
