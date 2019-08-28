module Accounting
  class IncomeStatementsController < ApplicationController
    before_action :authenticate_user!

    def index
      @income_statements = DataStore.income_statements.where(
                          "meta->>'branch_id' IN (?)",
                          @branches.pluck(:id)
                        )

      @income_statements = @income_statements.page(params[:page]).per(20)
    end

    def show
      @income_statement = DataStore.income_statements.find(params[:id])
      @record           = @income_statement
      @meta             = @income_statement.meta.with_indifferent_access
      @data             = @income_statement.data.with_indifferent_access
    end

    def destroy
      @income_statement  = DataStore.income_statements.find(params[:id])
      @income_statement.destroy!

      redirect_to accounting_income_statements_path
    end
  end
end
