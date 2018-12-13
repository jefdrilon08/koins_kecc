module Administration
  class ProjectTypeCategoriesController < ApplicationController
    before_action :authenticate_user!
    
    def index
      @project_type_categories  = ProjectTypeCategory.all.order("name ASC")
    end

    def new
      @project_type_category  = ProjectTypeCategory.new
    end

    def create
      @project_type_category  = ProjectTypeCategory.new(project_type_category_params)

      if @project_type_category.save
        redirect_to administration_project_type_category_path(@project_type_category)
      else
        render :new
      end
    end

    def edit
      @project_type_category  = ProjectTypeCategory.find(params[:id])
    end

    def update
      @project_type_category  = ProjectTypeCategory.find(params[:id])

      if @project_type_category.update(project_type_category_params)
        redirect_to administration_project_type_category_path(@project_type_category)
      else
        render :edit
      end
    end

    def show
      @project_type_category  = ProjectTypeCategory.find(params[:id])
    end

    def destroy
      @project_type_category  = ProjectTypeCategory.find(params[:id])
      @project_type_category.destroy!

      redirect_to project_type_categories_path
    end
  end
end
