module Api
  module V1
    class MonitoringController < ApiController
      before_action :authenticate_user!

      def accounting_entry_precision
        branch      = Branch.where(id: params[:branch_id]).first
        start_date  = params[:start_date].try(:to_date)
        end_date    = params[:end_date].try(:to_date)

        data  = ::Monitoring::AccountingEntryPrecision.new(
                  config: {
                    branch: branch,
                    start_date: start_date,
                    end_date: end_date
                  }
                ).execute!

        render json:  data
      end

      def accounting_entry_subsidiary_balancing
        branch  = Branch.where(id: params[:branch_id]).first
        as_of   = params[:as_of].try(:to_date)

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
