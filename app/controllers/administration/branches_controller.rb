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

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          text: "Branches"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: new_administration_branch_path,
          class: "fa fa-plus",
          text: "New Branch"
        }
      ]
    end

    def new
      @branch = Branch.new

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_branches_path,
          text: "Branches"
        },
        {
          text: "New"
        }
      ]

      @subheader_side_actions = []
    end

    def create
      @branch = Branch.new(branch_params)

      if @branch.save
        redirect_to administration_branch_path(@branch)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_branches_path,
            text: "Branches"
          },
          {
            text: "New"
          }
        ]

        @subheader_side_actions = []

        render :new
      end
    end

    def edit
      @branch = Branch.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_branches_path,
          text: "Branches"
        },
        {
          text: "Edit #{@branch.name}"
        }
      ]

      @subheader_side_actions = []
    end

    def update
      @branch = Branch.find(params[:id])

      if @branch.update(branch_params)
        redirect_to administration_branch_path(@branch)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_branches_path,
            text: "Branches"
          },
          {
            text: "Edit #{@branch.name}"
          }
        ]

        @subheader_side_actions = []

        render :edit
      end
    end

    def show
      @branch = Branch.find(params[:id])
      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_branches_path,
          text: "Branches"
        },
        {
          text: "#{@branch.name} (Current Date: #{::Utils::GetCurrentDate.new(config: { branch: @branch }).execute!.strftime("%b %d, %Y")})"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-edit",
          link: edit_administration_branch_path(@branch),
          class: "fa fa-pencil-alt",
          text: "Edit Branch"
        }
      ]
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
