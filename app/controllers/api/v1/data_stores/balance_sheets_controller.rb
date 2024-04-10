module Api
  module V1
    module DataStores
      class BalanceSheetsController < ActionController::Base
        before_action :authenticate_user!

        def queue
          @data_store_type  = "BALANCE_SHEET"
          @record           = DataStore.balance_sheets.where(id: params[:id]).first 
          @month            = params[:month].try(:to_i)
          @year             = params[:year]
          @branch           = Branch.where(id: params[:branch_id]).first

          @errors = ::Accounting::ValidateBalanceSheetGenerate.new(
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
                          month: @month,
                          branch_name: @branch.name,
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

            ProcessBalanceSheet.perform_later(args)

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
