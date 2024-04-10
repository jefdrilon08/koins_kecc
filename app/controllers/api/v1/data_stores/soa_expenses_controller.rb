module Api
  module V1
    module DataStores
      class SoaExpensesController < ApiController
        before_action :authenticate_user!

        def fetch
          record  = DataStore.soa_expenses.where(id: params[:id]).first

          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            records = record.data.with_indifferent_access[:records]

            # Get officers
            record.data["officers"] = records.select{ |o| 
                                        o[:officer].present? 
                                      }.map{ |o| o[:officer] }.uniq

            if params[:loan_product_id].present?
              records = records.select{ |o|
                          o[:loan_product][:id] == params[:loan_product_id]
                        }
            end

            if params[:center_id].present?
              records = records.select{ |o|
                          o[:center][:id] == params[:center_id]
                        }
            end

            if params[:officer_id].present?
              records = records.select{ |o|
                          o[:officer].present?
                        }.select{ |o|
                          o[:officer][:id] == params[:officer_id]
                        }
            end

            record.data["records"] = records

            render json: record
          end
        end

        def queue
          data_store_type = params[:data_store_type] || "SOA_EXPENSES"
          start_date      = params[:start_date].try(:to_date)
          end_date        = params[:end_date].try(:to_date)
          branch          = @branches.select{ |b| b[:id] == params[:branch_id] }.first

          errors  = ::DataStores::ValidateSoaExpensesQueue.new(
                      config: {
                        branch: branch,
                        start_date: start_date,
                        end_date: end_date,
                      }
                    ).execute!

          if errors[:messages].size == 0
            record  = DataStore.soa_expenses.where(
                        "meta->>'branch_id' = ? AND CAST(meta->>'start_date' AS date) = ? AND CAST(meta->>'end_date' AS date) = ?",
                        params[:branch_id],
                        start_date,
                        end_date
                      ).first

            if record.blank?
              record  = DataStore.create!(
                          meta: {
                            branch_id: branch.id,
                            branch_name: branch.name,
                            start_date: start_date,
                            end_date: end_date,
                            data_store_type: data_store_type
                          },
                          data: {
                            status: "processing"
                          }
                        )
            else
              record.update!(
                status: "processing"
              )
            end

            args = {
              id: record.id,
              data_store_type: data_store_type
            }

            ProcessSoaExpenses.perform_later(args)

            render json: { message: "ok" }
          else
            render json: errors, status: 400
          end
        end
      end
    end
  end
end
