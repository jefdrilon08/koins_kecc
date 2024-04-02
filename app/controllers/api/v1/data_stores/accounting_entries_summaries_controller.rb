module Api
  module V1
    module DataStores
      class AccountingEntriesSummariesController < ApiController
        before_action :authenticate_user!

        def queue
          data_store_type = params[:data_store_type] || "ACCOUNTING_ENTRIES_SUMMARY"
          start_date      = params[:start_date].try(:to_date)
          end_date        = params[:end_date].try(:to_date)
          book            = params[:book]
          #branch          = @branches.where(id: params[:branch_id]).first
          branch          = @branches.select{ |o| o[:id] == params[:branch_id] }.first

          errors  = ::DataStores::ValidateAccountingEntriesSummariesQueue.new(
                      config: {
                        branch: branch,
                        start_date: start_date,
                        end_date: end_date,
                        book: book
                      }
                    ).execute!

          if errors[:messages].size == 0
            record  = DataStore.accounting_entries_summaries.where(
                        "meta->>'branch_id' = ? AND CAST(meta->>'start_date' AS date) = ? AND CAST(meta->>'end_date' AS date) = ? AND meta->>'book' = ?",
                        params[:branch_id],
                        start_date,
                        end_date,
                        book
                      ).first

            if record.blank?
              record  = DataStore.create!(
                          meta: {
                            branch_id: branch.id,
                            branch_name: branch.name,
                            start_date: start_date,
                            end_date: end_date,
                            book: book,
                            data_store_type: data_store_type
                          },
                          data: {
                            status: "processing"
                          }
                        )
            end

            record.update!(status: "processing")

            args = {
              record_id: record.id,
              data_store_type: data_store_type
            }

            ProcessAccountingEntriesSummary.perform_later(args)

            render json: { message: "ok" }
          else
            render json: errors, status: 400
          end
        end
      end
    end
  end
end
