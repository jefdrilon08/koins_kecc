module Api
  module V1
    module DataStores
      class AccountingEntriesSummariesController < ApplicationController
        before_action :authenticate_user!

        def queue
          data_store_type = params[:data_store_type] || "ACCOUNTING_ENTRIES_SUMMARY"
          start_date      = params[:start_date].try(:to_date)
          end_date        = params[:end_date].try(:to_date)
          branch          = @branches.where(id: params[:branch_id]).first

          errors  = ::DataStores::ValidateAccountingEntriesSummariesQueue.new(
                      config: {
                        branch: branch,
                        start_date: start_date,
                        end_date: end_date
                      }
                    ).execute!

          if errors.empty?
            record  = DataStore.accounting_entries_summaries.where(
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
            end

            args = {
              record_id: record.id,
              data_store_type: data_store_type
            }

            ProcessAccountingEntriesSummaries.perform_later(args)

            render json: { message: "ok" }
          else
            render json: errors, status: 400
          end
        end
      end
    end
  end
end
