module Administration
  class LoanProductCategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @loan_product_categories  = LoanProductCategory.select("*").order("name ASC")

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          text: "Loan Product Categories"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: new_administration_loan_product_category_path,
          class: "fa fa-plus",
          text: "New Loan Product Category"
        }
      ]
    end

    def show
      @loan_product_category  = LoanProductCategory.find(params[:id])
      @loan_products          = @loan_product_category.loan_products

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_loan_product_categories_path,
          text: "Loan Product Categories"
        },
        {
          text: "#{@loan_product_category.name}"
        }
      ]

      @subheader_side_actions = []

      @subheader_side_actions << {
        link: edit_administration_loan_product_category_path(@loan_product_category),
        class: "fa fa-pencil-alt",
        text: "Edit"
      }

      @payload = {
        id: @loan_product_category.id
      }
    end

    def new
      @loan_product_category = LoanProductCategory.new

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_loan_product_categories_path,
          text: "Loan Product Categories"
        },
        {
          text: "New Loan Product Category"
        }
      ]

      @subheader_side_actions = []
    end

    def create
      @loan_product_category = LoanProductCategory.new(loan_product_category_params)

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_loan_product_categories_path,
          text: "Loan Product Categories"
        },
        {
          text: "New Loan Product Category"
        }
      ]

      @subheader_side_actions = []

      if @loan_product_category.save
        ActivityLog.create!(
          content: "#{current_user.full_name} created loan_product_category #{@loan_product_category}",
          activity_type: "create",
          data: {
            user_id: current_user.id,
            loan_product_category: @loan_product_category
          }
        )

        redirect_to administration_loan_product_category_path(@loan_product_category)
      else

        render :new
      end
    end

    def edit
      @loan_product_category = LoanProductCategory.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_loan_product_categories_path,
          text: "Loan Product Categories"
        },
        {
          text: "Edit: #{@loan_product_category.name}"
        }
      ]

      @subheader_side_actions = []
    end

    def destroy
      @loan_product_category = LoanProductCategory.find(params[:id])

      ActivityLog.create!(
        content: "#{current_user.full_name} deleted loan_product_category #{@loan_product_category}",
        activity_type: "delete",
        data: {
          user_id: current_user.id,
          loan_product_category: @loan_product_category
        }
      )

      @loan_product_category.destroy!

      redirect_to administration_loan_product_categories_path
    end

    def update
      @loan_product_category = LoanProductCategory.find(params[:id])

      if @loan_product_category.update(loan_product_category_params)

        ActivityLog.create!(
          content: "#{current_user.full_name} updated loan_product_category #{@loan_product_category}",
          activity_type: "modification",
          data: {
            user_id: current_user.id,
            loan_product_category: @loan_product_category
          }
        )

        redirect_to administration_loan_product_category_path(@loan_product_category)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_loan_product_categories_path,
            text: "Loan Product Categories"
          },
          {
            text: "Edit: #{@loan_product_category.name}"
          }
        ]

        @subheader_side_actions = []

        render :edit
      end
    end

    private

    def loan_product_category_params
      params.require(:loan_product_category).permit!
    end
  end
end
