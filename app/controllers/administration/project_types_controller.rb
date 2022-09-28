module Administration
  class ProjectTypesController < ApplicationController
    before_action :authenticate_user!

    def index
      @project_types  = ProjectType.all.order("name ASC")

      @subheader_items = [
        { text: "Administration" },
        { text: "Project Types" }
      ]

      @subheader_side_actions = [
        { class: "fa fa-plus", text: "New Project Type", link: new_administration_project_type_path }
      ]
    end
    def new
      @project_type  = ProjectType.new
      @subheader_items = [
        { text: "Administration" },
        { text: "Project Types", path: administration_project_types_path, is_link: true },
        { text: "New" }
      ]

    end 
    def create
      @project_type = ProjectType.new(project_type_params)
      if @project_type.save
        redirect_to administration_project_types_path(@project_type)
      else
        @subheader_items = [
          { text: "Administration" },
          { text: "Project Types", path: administration_project_types_path, is_link: true },
          { text: "New" }
        ]

        render :new
      end
    end
    def update
      @project_type  = ProjectType.find(params[:id])

      if @project_type.update(project_type_params)
        redirect_to administration_project_types_path(@project_type)
      else
        @subheader_items = [
          { text: "Administration" },
          { text: "Project Type", path: administration_project_types_path, is_link: true },
          { text: "Edit: #{@project_type.id}" }
        ]

        render :edit
      end
    end

 
    def show
      @project_type  = ProjectType.find(params[:id])

      @subheader_items = [
        { text: "Administration" },
        { text: "Project Types", path: administration_project_types_path, is_link: true },
        { text: "#{@project_type.id}" }
      ]
      @subheader_side_actions = [
        {
          id: "btn-edit",
          link: edit_administration_project_type_path(@project_type),
          class: "fa fa-pencil-alt",
          text: "Edit Project Type"
        },
         {
          text: "Delete",
          class: "fa fa-times",
          path: administration_project_types_path(@project_type),
          data: {
            method: :delete,
            confirm: "Are you sure?"
          }
        }

      ]
    end
    
    def edit
      @project_type  = ProjectType.find(params[:id])
      @subheader_items = [
        { text: "Administration" },
        { text: "Project Type Categories", path: administration_project_types_path, is_link: true },
        { text: "Edit: #{@project_type.id}" }
      ]
    end


    private

    def load_user!
      @user = User.find(params[:id])
    end

    def project_type_params
      params.require(:project_type).permit!
    end

  end
end 
