module Api
  module V1
    class MonitoringController < ApiController
      before_action :authenticate_user!

      def accounting_entry_subsidiary_balancing
        branch  = Branch.where(id: params[:branch_id]).first
        as_of   = params[:as_of].try(:to_date) || Date.today

        data  = ::Monitoring::AccountingEntrySubsidiaryBalancing.new(
                  config: {
                    branch: branch,
                    as_of: as_of
                  }
                ).execute!

        render json: data
      end
    end
  end
end
