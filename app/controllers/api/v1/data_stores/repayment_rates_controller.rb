module Api
  module V1
    module DataStores
      class RepaymentRatesController < ApiController
        before_action :authenticate_app_request!
        before_action :authenticate_core_user!, except: [:fetch]

        def fetch
          record  = ReadOnlyDataStore.repayment_rates.where(id: params[:id]).first

          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            records = record.data.with_indifferent_access[:records]
            #records = record.data_json_dump_url

            if params[:center_id].present?
              records = records.select{ |o|
                          o[:center][:id] == params[:center_id]
                        }
            end

            if params[:loan_product_id].present?
              records = records.select{ |o|
                          o[:loan_product][:id] == params[:loan_product_id]
                        }
            end

            if params[:officer_id].present?
              records = records.select{ |o|
                          o[:officer][:id] == params[:officer_id]
                        }
            end

            record.data["records"] = records

            render json: record
          end
        end

        def queue
          data_store_type = params[:data_store_type] || "REPAYMENT_RATES"
          as_of           = params[:as_of].try(:to_date)

          # fetch branches according to @core_user since we're using API calls
          @default_branch_name = Settings.try(:defaults).try(:default_branch).try(:name)
          @branches = ReadOnlyBranch
            .joins(user_branches: :user)
            .where(user_branches: { active: true, user_id: @core_user.id })
            .order("name#{" = '#{@default_branch_name}'" if @default_branch_name} ASC")

          branch = @branches.select{ |o| o[:id] == params[:branch_id] }.first

          errors  = ::DataStores::ValidateRepaymentRatesQueue.new(
                      config: {
                        branch: branch,
                        as_of: as_of
                      }
                    ).execute!

          if errors[:messages].size == 0
            record  = DataStore.select("id, meta, status").where(
                        "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                        params[:branch_id],
                        as_of
                      ).first

            if record.blank?
              record  = DataStore.create!(
                          meta: {
                            branch_id: branch.id,
                            branch_name: branch.name,
                            as_of: as_of,
                            data_store_type: data_store_type
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

            ProcessRepaymentRates.perform_later(args)

            render json: { message: "ok", id: record.id, status: "processing" }
          else
            render json: errors, status: 400
          end
        end
      end
    end
  end
end
