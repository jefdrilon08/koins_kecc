module Api
  module V1
    module DataStores
      class IncomeStatementsController < ActionController::Base
        before_action :authenticate_user!

        def queue
          @data_store_type  = "INCOME_STATEMENT"
          @record           = DataStore.income_statements.where(id: params[:id]).first 
          @month            = params[:month]
          @year             = params[:year]
          @branch           = Branch.where(id: params[:branch_id]).first

          @errors = ::Accounting::ValidateIncomeStatementGenerate.new(
                      config: {
                        branch: @branch,
                        month: @month,
                        year: @year
                      }
                    ).execute!

          if @errors[:full_messages].any?
            render json: @errors, status: 400
          elsif @record.blank?
            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          month: @month,
                          year: @year,
                          data_store_type: @data_store_type,
                          progress: 0
                        },
                        data: {
                          status: "processing"
                        }
                      )

            args = {
              id: @record.id,
              data_store_type: @data_store_type
            }

            ProcessIncomeStatement.perform_later(args)

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
