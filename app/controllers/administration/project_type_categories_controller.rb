module Administration
  class ProjectTypeCategoriesController < ApplicationController
    before_action :authenticate_user!
    
    def index
      @project_type_categories  = ProjectTypeCategory.all.order("name ASC")

      @subheader_items = [
        { text: "Administration" },
        { text: "Project Type Categories" }
      ]

      @subheader_side_actions = [
        { class: "fa fa-plus", text: "New Project Type Category", link: new_administration_project_type_category_path }
      ]
    end

    def new
      @project_type_category  = ProjectTypeCategory.new
      
      @subheader_items = [
        { text: "Administration" },
        { text: "Project Type Categories", path: administration_project_type_categories_path, is_link: true },
        { text: "New" }
      ]
    end

    def create
      @project_type_category  = ProjectTypeCategory.new(project_type_category_params)
      if @project_type_category.save
        redirect_to administration_project_type_category_path(@project_type_category)
      else
        @subheader_items = [
          { text: "Administration" },
          { text: "Project Type Categories", path: administration_project_type_categories_path, is_link: true },
          { text: "New" }
        ]

        render :new
      end
    end

    def edit
      @project_type_category  = ProjectTypeCategory.find(params[:id])
      @subheader_items = [
        { text: "Administration" },
        { text: "Project Type Categories", path: administration_project_type_categories_path, is_link: true },
        { text: "Edit: #{@project_type_category.id}" }
      ]
    end

    def update
      @project_type_category  = ProjectTypeCategory.find(params[:id])

      if @project_type_category.update(project_type_category_params)
        redirect_to administration_project_type_category_path(@project_type_category)
      else
        @subheader_items = [
          { text: "Administration" },
          { text: "Project Type Categories", path: administration_project_type_categories_path, is_link: true },
          { text: "Edit: #{@project_type_category.id}" }
        ]

        render :edit
      end
    end

    def show
      @project_type_category  = ProjectTypeCategory.find(params[:id])

      @subheader_items = [
        { text: "Administration" },
        { text: "Project Type Categories", path: administration_project_type_categories_path, is_link: true },
        { text: "#{@project_type_category.id}" }
      ]
      @subheader_side_actions = [
        {
          id: "btn-edit",
          link: edit_administration_project_type_category_path(@project_type_category),
          class: "fa fa-pencil-alt",
          text: "Edit Branch"
        },
         {
          text: "Delete",
          class: "fa fa-times",
          path: administration_project_type_category_path(@project_type_category),
          data: {
            method: :delete,
            confirm: "Are you sure?"
          }
        }

      ]
    end

    def destroy
      @project_type_category  = ProjectTypeCategory.find(params[:id])
      @project_type_category.destroy!

      redirect_to project_type_categories_path
    end
    
    private

    def load_user!
      @user = User.find(params[:id])
    end

    def project_type_category_params
      params.require(:project_type_category).permit!
    end

  end
end
