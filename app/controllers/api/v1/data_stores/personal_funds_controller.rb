module Api
  module V1
    module DataStores
      class PersonalFundsController < ApiController
        before_action :authenticate_app_request!
        before_action :authenticate_core_user!, except: [:fetch]

        def download_excel
          record = ReadOnlyDataStore.personal_funds.where(id: params[:id]).first

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
          @record = ReadOnlyDataStore.personal_funds.find_by_id(params[:id])

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
          data_store_type = params[:data_store_type] || "PERSONAL_FUNDS"
          record          = DataStore.personal_funds.where(id: params[:id]).first 
          branch          = Branch.where(id: params[:branch_id]).first
          as_of           = params[:as_of].try(:to_date)

          errors  = ::DataStores::ValidateQueuePersonalFunds.new(
                      config: {
                        branch: branch,
                        as_of: as_of
                      }
                    ).execute!

          if errors[:full_messages].size > 0
            render json: { errors: errors }, status: 400
          else
            if record.blank?

              record = DataStore.create!(
                          meta: {
                            branch_id: branch.id,
                            branch_name: branch.name,
                            as_of: as_of,
                            data_store_type: data_store_type,
                            progress: 0
                          },
                          data: {
                            status: "processing"
                          }
                        )
            end

            record.update!(status: "processing")

            args = {
              id: record.id,
              data_store_type: data_store_type
            }

            ProcessPersonalFunds.perform_later(args)

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
