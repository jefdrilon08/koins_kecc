module Api
  module Members
    class LoanApplicationsController < ::Api::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!

      def index
        loan_applications = LoanApplication
                              .where("member_id = ?", @current_member.id)
                              .where("status IN (?)", ["pending", "processing", "reject", "rejected"])
                              .order("date_applied ASC")
                              .map do |loan_application|
                                # Check if the status is 'reject' or 'rejected' and include the reason
                                loan_application_hash = loan_application.to_h
                                if loan_application.status.in?(["reject", "rejected"])
                                  loan_application_hash[:reason] = loan_application.data["reason_approve_reject"] || loan_application.data["reason_of_reject"]
                                end
                                loan_application_hash
                              end
        render json: { loan_applications: loan_applications }
      end
    end
  end
end
