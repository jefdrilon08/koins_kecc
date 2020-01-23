module Api
  module V1
    module DataStores
      class PersonalFundsController < ApplicationController
        before_action :authenticate_user!

        def download_excel
          record = DataStore.personal_funds.where(id: params[:id]).first

          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            records = record.data.with_indifferent_access[:records]

            if params[:officer_id].present?
              records = records.select{ |o|
                          o[:officer][:id] == params[:officer_id]
                        }
            end

            if params[:center_id].present?
              records = records.select{ |o|
                          o[:center][:id] == params[:center_id]
                        }
            end

            record.data["records"] = records

            # Gumawa ng file
            excel_file  = ::DataStores::GeneratePersonalFundReportExcel.new(config: { record: record }).execute!
            filename    = "personal_funds_#{Time.now.to_i}.xlsx"

            excel_file.serialize "#{Rails.root}/tmp/#{filename}"

            render json: { filename: filename }
          end
        end

        def fetch
          @record = DataStore.personal_funds.where(id: params[:id]).first

          if @record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            records = @record.data.with_indifferent_access[:records]

            if params[:officer_id].present?
              records = records.select{ |o|
                          o[:officer][:id] == params[:officer_id]
                        }
            end

            if params[:center_id].present?
              records = records.select{ |o|
                          o[:center][:id] == params[:center_id]
                        }
            end

            @record.data["records"] = records

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
                          data_store_type: @data_store_type,
                          progress: 0
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          @record.update!(status: "processing")

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
