module Api
  module V1
    module DataStores
      class IcprController < ApplicationController
        before_action :authenticate_user!

        def fetch
          @record = DataStore.icpr.where(id: params[:id]).first

          if @record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            render json: @record
          end
        end

        def queue
          @data_store_type  = params[:data_store_type] || "ICPR"
          @include_centers  = false
          @record           = DataStore.icpr.where(id: params[:id]).first 

          if @record.blank?
            @branch       = Branch.find(params[:branch_id])
            @start_date   = params[:start_date].to_date
            @end_date     = params[:end_date].to_date
            @equity_rate  = params[:equity_rate].to_f

            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          start_date: @start_date,
                          end_date: @end_date,
                          equity_rate: @equity_rate,
                          data_store_type: @data_store_type,
                          progress: 0
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          args = {
            id: @record.id,
            data_store_type: @data_store_type
            #closing_date: Date.today
          }

          ProcessIcpr.perform_later(args)

          render json: { message: "ok" }
        end


      def approve
        icpr  = DataStore.find(params[:id])
      
        config  = {
          icpr: icpr,
          user: current_user
        }

 #       errors  = ::MonthlyClosingCollections::ValidateApprove.new(
 #                   config: config
 #                 ).execute!

 #       if errors[:messages].size == 0
          icpr  = ::DataStores::ApproveIcpr.new(
                                          config: config
                                        ).execute!

          render json: { id: icpr.id }
 #       else
 #         render json: errors, status: 400
 #       end
      end






      end
    end
  end
end
