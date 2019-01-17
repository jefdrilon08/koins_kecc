module Api
  module V1
    module DataStores
      class YearEndClosingsController < ApplicationController
        before_action :authenticate_user!

        def queue
          @data_store_type  = "YEAR_END_CLOSING"
          @record           = DataStore.year_end_closings.where(id: params[:id]).first 

          @errors = ::Closing::ValidateYearEndGenerate.new(
                      config: {
                        branch: Branch.where(id: params[:branch_id]).first,
                        closing_date: params[:closing_date].try(:to_date)
                      }
                    ).execute!

          if @errors[:full_messages].size > 0
            render json: @errors, status: 400
          elsif @record.blank?
            @branch       = Branch.find(params[:branch_id])
            @closing_date = params[:closing_date].to_date

            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          closing_date: @closing_date,
                          year: @closing_date.year,
                          data_store_type: @data_store_type,
                          progress: 0
                        },
                        data: {
                          status: "processing"
                        }
                      )

            args = {
              id: @record.id,
              data_store_type: @data_store_type,
              user_id: current_user.id
            }

            ProcessYearEndClosing.perform_later(args)

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
