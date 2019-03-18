module Api
  module V1
    module DataStores
      class XWeeksToPayController < ApplicationController
        before_action :authenticate_user!

        def queue
          @data_store_type  = "X_WEEKS_TO_PAY"
          @as_of            = params[:as_of].try(:to_date) || Date.today
          @x                = params[:x].try(:to_i) || 4
          @branch           = Branch.find(params[:branch_id])

          @record = DataStore.x_weeks_to_pay.where(
                      "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ? AND CAST(meta->>'x' AS int) = ?",
                      @branch.id,
                      @as_of,
                      @x
                    ).first

          if @record.blank?
            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          branch: {
                            id: @branch.id,
                            name: @branch.name
                          },
                          as_of: @as_of,
                          x: @x,
                          data_store_type: @data_store_type
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          args  = {
            data_store_id: @record.id,
            branch_id: @branch.id,
            as_of: @as_of.to_s,
            x: @x
          }

          ProcessXWeeksToPay.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
