module Api
  module V1
    module DataStores
      class PersonalFundsController < ApplicationController
        before_action :authenticate_user!

        def fetch
          @record = DataStore.personal_funds.where(id: params[:id]).first

          if @record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            render json: @record
          end
        end

        def queue
          @data_store_type  = params[:data_store_type] || "PERSONAL_FUNDS"
          @include_centers  = false
          @record           = DataStore.personal_funds.where(id: params[:id]).first 

          if @record.blank?
            @branch = Branch.find(params[:branch_id])
            @as_of  = params[:as_of].to_date

            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          as_of: @as_of,
                          data_store_type: @data_store_type
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          args = {
            id: @record.id,
            data_store_type: @data_store_type
          }

          ProcessPersonalFunds.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
