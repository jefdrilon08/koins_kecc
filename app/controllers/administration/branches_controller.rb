module Administration
  class BranchesController < ApplicationController
    before_action :authenticate_user!

    def index
      sql = "
        SELECT 
          branches.*, 
          count(centers.*) AS center_count
        FROM branches 
        INNER JOIN centers
        ON centers.branch_id = branches.id
        GROUP BY branches.id
        ORDER BY branches.name ASC
      "
      @branches  = Branch.find_by_sql(sql)
    end

    def new
      @branch = Branch.new
    end

    def create
      @branch = Branch.new(branch_params)

      if @branch.save
        redirect_to administration_branch_path(@branch)
      else
        render :new
      end
    end

    def edit
      @branch = Branch.find(params[:id])
    end

    def update
      @branch = Branch.find(params[:id])

      if @branch.update(branch_params)
        redirect_to administration_branch_path(@branch)
      else
        render :edit
      end
    end

    def show
      @branch = Branch.find(params[:id])
    end

    private

    def load_user!
      @branch = Branch.find(params[:id])
    end

    def branch_params
      params.require(:branch).permit!
    end
  end
end
