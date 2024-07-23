module Api
  class ClosingRecordsController < ::Api::FrontController

    def index
      branch        = ReadOnlyBranch.find_by_id(params[:branch_id])
      closing_date  = params[:closing_date]

      cmd = ::ClosingRecords::ValidateFetchClosingRecords.new(
        branch:       branch,
        closing_date: closing_date
      )

      cmd.execute!

      if cmd.errors.size > 0
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        cmd = ::ClosingRecords::FetchClosingRecords.new(
          branch:       branch,
          closing_date: closing_date
        )

        cmd.execute!

        render json: { records: cmd.records }
      end
    end

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
        branch:                 branch,
        record_type:            record_type,
        closing_date:           closing_date,
        data_store:             data_store,
        user:                   current_user
      )

      cmd.execute!

      if cmd.errors.size > 0
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        cmd = ::ClosingRecords::Create.new(
          branch:                 branch,
          record_type:            record_type,
          closing_date:           closing_date,
          data_store:             data_store,
          user:                   current_user
        )

        cmd.execute!

        render json: { message: "ok" }
      end
    end
 
    def remove
    record_type = params[:type]
    data_store_id = params[:data_store_id]

    id = AdministrationBranchClosingRecord.where(data_store_id: data_store_id, record_type: record_type).last.id
    AdministrationBranchClosingRecord.find(id).destroy!
    
    #cmd = ::ClosingRecords::RemoveRecord.new(
    #record_type: record_type,
    #data_store_id: data_store_id
    #)

    render json: { message: "Done" }
  end


  end
end
