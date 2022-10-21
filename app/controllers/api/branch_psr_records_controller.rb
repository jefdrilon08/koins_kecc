module Api
  class BranchPsrRecordsController < ::Api::FrontController
    before_action :authenticate_user!

    def fetch
      branch  = Branch.find_by_id(params[:branch_id])
      year    = params[:year].try(:to_i) || Date.today.year

      branch_psr_records = BranchPsrRecord.where(
        branch_id: branch.id
      ).order(
        "closing_date ASC"
      )

      records = branch_psr_records.map{ |o|
        o.to_h
      }

      render json: { records: records }
    end
  end
end
