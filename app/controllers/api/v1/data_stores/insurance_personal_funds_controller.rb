module Api
  module V1
    module DataStores
      class InsurancePersonalFundsController < ActionController::Base
        before_action :authenticate_app_request!
        before_action :authenticate_core_user!, except: [:fetch]

        def download_excel
          record = ReadOnlyDataStore.insurance_personal_funds.where(id: params[:id]).first

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
            excel_file  = ::DataStores::GenerateInsurancePersonalFundReportExcel.new(config: { record: record }).execute!
            filename    = "insurance_personal_funds_#{Time.now.to_i}.xlsx"

            excel_file.serialize "#{Rails.root}/tmp/#{filename}"

            render json: { filename: filename }
          end
        end

        def fetch
          @record = ReadOnlyDataStore.insurance_personal_funds.find_by_id(params[:id])

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
          data_store_type = params[:data_store_type] || "INSURANCE_PERSONAL_FUNDS"
          record          = DataStore.insurance_personal_funds.where(id: params[:id]).first 
          branch          = Branch.where(id: params[:branch_id]).first
          as_of           = params[:as_of].try(:to_date)
          member_status   = params[:member_status]

          errors  = ::DataStores::ValidateQueueInsurancePersonalFunds.new(
                      config: {
                        branch: branch,
                        as_of: as_of,
                        member_status: member_status
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
                            member_status: member_status,
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

            ProcessInsurancePersonalFunds.perform_later(args)

            render json: { message: "ok" }
          end
        end

        def queue_bulk
          @as_of           = params[:as_of].try(:to_date)
          @data_store_type = params[:data_store_type] || "INSURANCE_PERSONAL_FUNDS"
          member_statuses = ["active", "inactive"]

          Branch.all.each do |branch|
            member_statuses.each do |member_status|  
              
              rec = DataStore.insurance_personal_funds.where("meta->>'branch_id' = ? AND DATE(meta->>'as_of') = ? AND meta->>'member_status' = ?", branch.id, @as_of, member_status).first

              if rec.nil?
                record = DataStore.create!(
                            meta: {
                              branch_id: branch.id,
                              branch_name: branch.name,
                              as_of: @as_of,
                              member_status: member_status,
                              data_store_type: @data_store_type,
                              progress: 0
                            },
                            data: {
                              status: "processing"
                            }
                          )

                args = {
                  id: record.id,
                  data_store_type: @data_store_type
                }

                ProcessInsurancePersonalFunds.perform_later(args)
              end
            end
          end
        end
      end
    end
  end
end
