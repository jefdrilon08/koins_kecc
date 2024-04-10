module Api
  module V1
    class RiskProfilesController < ApiController
      #skip_before_action :verify_authenticity_token
      before_action :authenticate_user!, except: [:fetch_daily_metric, :fetch_prev_metric]

      def fetch_daily_metric    
        config = {
            test: params[:as_of]
        }
        cmd = ::RiskProfiles::BuildDailyMetrics.new(config: config).execute!

        render json: cmd
      end
      
      def fetch_prev_metric    
        config = {
            test: params[:as_of]
        }
        cmd = ::RiskProfiles::BuildYearEndMetrics.new(config: config).execute!

        render json: cmd
      end
    end
  end
end

