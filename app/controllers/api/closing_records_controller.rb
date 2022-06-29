module Api
  class ClosingRecordsController < ::Api::FrontController
    def records
      branch        = ReadOnlyBranch.find_by_id(params[:branch_id])
      record_type   = params[:record_type]
      closing_date  = params[:closing_date]

      cmd = ::ClosingRecords::ValidateFetchDataStores.new(
        branch:       branch,
        record_type:  record_type,
        closing_date: closing_date
      )

      cmd.execute!

      if cmd.errors.size > 0
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        cmd = ::ClosingRecords::FetchDataStores.new(
          branch:       branch,
          record_type:  record_type,
          closing_date: closing_date
        )

        cmd.execute!

        render json: { records: cmd.records }
      end
    end

    def create
      branch        = ReadOnlyBranch.find_by_id(params[:branch_id])
      data_store    = ReadOnlyDataStore.find_by_id(params[:data_store_id])
      record_type   = params[:record_type]
      closing_date  = params[:closing_date]

      cmd = ::ClosingRecords::ValidateCreate.new(
        branch:       branch,
        record_type:  record_type,
        closing_date: closing_date,
        data_store:   data_store
      )

      cmd.execute!

      if cmd.errors.size > 0
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        cmd = ::ClosingRecords::Create.new(
          branch:       branch,
          record_type:  record_type,
          closing_date: closing_date,
          data_store:   data_store
        )

        cmd.execute!

        render json: { message: "ok" }
      end
    end
  end
end
