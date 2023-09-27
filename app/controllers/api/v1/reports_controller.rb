module Api
  module V1
    class ReportsController < ActionController::API
      def member_reports
        branch_id     = params[:branch_id]
        insurance_status = params[:insurance_status]
        member_type = params[:member_type]
        status = params[:status]
        start_date    = params[:start_date]
        end_date      = params[:end_date]


        data = Reports::MemberReports.new(
                  branch_id: branch_id,
                  member_type: member_type,
                  insurance_status: insurance_status,
                  status: status,
                  start_date: start_date,
                  end_date: end_date
                ).execute!

        data[:download_url] = member_reports_path(
                                branch_id: branch_id,
                                member_type: member_type,
                                insurance_status: insurance_status,
                                status: status,
                                start_date: start_date,
                                download: true,
                                end_date: end_date
                              )

        render json: data
      end

      def member_quarterly_reports
        start_date    = params[:start_date]
        end_date      = params[:end_date]

        data = Reports::MemberQuarterlyReports.new(
                  start_date: start_date,
                  end_date: end_date
                ).execute!

        data[:download_url] = member_quarterly_reports_path(
                                start_date: start_date,
                                download: true,
                                end_date: end_date
                              )
        render json: data
      end

      def insurance_quarterly_reports
        start_date    = params[:start_date]
        end_date      = params[:end_date]

        data = Reports::InsuranceQuarterlyReports.new(
                  start_date: start_date,
                  end_date: end_date
                ).execute!

        data[:download_url] = insurance_quarterly_reports_path(
                                start_date: start_date,
                                download: true,
                                end_date: end_date
                              )
        render json: data
      end

      def member_counts
        start_date    = params[:start_date]
        end_date      = params[:end_date]

        if start_date.to_date.year == end_date.to_date.year
          data = Reports::MemberCounts.new(
                  start_date: start_date,
                  end_date: end_date
                ).execute!

          data[:download_url] = member_counts_path(
                                start_date: start_date,
                                download: true,
                                end_date: end_date
                              )
          render json: data
        else
          render json: errors, status: 400
        end
      end
      
      def summary_of_certificates_and_policies
        branch_id     = params[:branch_id]
        plan_type = params[:plan_type]
        as_of      = params[:as_of]

        data = Reports::SummaryOfCertificatesAndPolicies.new(
                  branch_id: branch_id,
                  as_of: as_of,
                  plan_type: plan_type
                ).execute!

        data[:download_url] = summary_of_certificates_and_policies_path(
                                branch_id: branch_id,
                                plan_type: plan_type,
                                download: true,
                                as_of: as_of
                              )

        render json: data
      end

      def savings_insurance_transfer_reports
        branch        = params[:branch]
        start_date    = params[:start_date]
        end_date      = params[:end_date]

        data = Reports::GenerateSavingsInsuranceTransferReports.new(
                  branch_id: branch_id,
                  start_date: start_date,
                  end_date: end_date
                ).execute!

        data[:download_url] = savings_insurance_transfer_reports_path(
                                branch_id: branch_id,
                                start_date: start_date,
                                download: true,
                                end_date: end_date
                              )

        render json: data
      end

      def claims_processing_time_report
        branch        = params[:branch]
        start_date    = params[:start_date]
        end_date      = params[:end_date]

        data = Reports::GenerateClaimsProcessingTimeReport.new(
                  branch_id: branch,
                  start_date: start_date,
                  end_date: end_date
                ).execute!

        data[:download_url] = claims_processing_time_report_path(
                                branch_id: branch,
                                start_date: start_date,
                                download: true,
                                end_date: end_date
                              )

        render json: data
      end

      def claims_processing_time_report_summary
        branch        = params[:branch]
        start_date    = params[:start_date]
        end_date      = params[:end_date]

        data = Reports::GenerateClaimsProcessingTimeReportSummary.new(
                  branch_id: branch,
                  start_date: start_date,
                  end_date: end_date
                ).execute!

        data[:download_url] = claims_processing_time_report_summary_path(
                                branch_id: branch,
                                start_date: start_date,
                                download: true,
                                end_date: end_date
                              )

        render json: data
      end

      def reclassified_report
        branch        = params[:branch]
        # start_date    = params[:start_date]
        # end_date      = params[:end_date]

        data = Reports::GenerateReclassifiedReport.new(
                  branch_id: branch,
                  # start_date: start_date,
                  # end_date: end_date
                ).execute!

        data[:download_url] = claims_processing_time_report_path(
                                branch_id: branch,
                                # start_date: start_date,
                                # end_date: end_date,
                                download: true
                              )

        render json: data
      end

    end
  end
end

