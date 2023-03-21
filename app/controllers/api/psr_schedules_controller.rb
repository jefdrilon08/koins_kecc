module Api
  class PsrSchedulesController < ApiController
    before_action :authenticate_request!

    def generate
      validator = ::PsrSchedules::ValidateGenerate.new(
        branch_ids: params[:branch_ids],
        year:       params[:year],
        month:      params[:month]
      )

      validator.execute!

      if validator.valid?
        cmd = ::PsrSchedules::Generate.new(
          branch_ids: params[:branch_ids],
          year:       params[:year],
          month:      params[:month]
        )

        cmd.execute!

        render json: cmd.data
      else
        render json: { errors: validator.errors }, status: :unprocessable_entity
      end
    end
  end
end
