module Accounting
  class IncomeStatementsController < ApplicationController
    before_action :authenticate_user!

    def index
      @income_statements  = DataStore.income_statements.where(
                              "meta->>'branch_id' IN (?)",
                              @branches.pluck(:id)
                            )

      @income_statements = @income_statements.page(params[:page]).per(20)

      @subheader_items = [
        {
          text: "Income Statements"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
    end

    def show
      @income_statement = DataStore.income_statements.find(params[:id])
      @record           = @income_statement
      @meta             = @income_statement.meta.with_indifferent_access
      @data             = @income_statement.data.with_indifferent_access

      @subheader_items = [
        {
          is_link: true,
          path: accounting_income_statements_path,
          text: "Income Statements"
        },
        {
          text: "#{@meta["branch_name"]} #{@meta["year"]}"
        }
      ]

      @subheader_side_actions = []

      if !@income_statement.processing?
        @subheader_side_actions << {
          id: "",
          link: accounting_income_statement_path(@income_statement),
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }
      end
    end

    def destroy
      @income_statement  = DataStore.income_statements.find(params[:id])
      @income_statement.destroy!

      redirect_to accounting_income_statements_path
    end
  end
end
