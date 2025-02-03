class InsuranceLoanBundleEnrollmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @insurance_loan_bundle_enrollments = InsuranceLoanBundleEnrollment.select("*").where(branch_id: @branches.pluck(:id))

    @center   = Center.where(id: params[:center_id]).first
    @q        = params[:q]
    @branch   = Branch.where(id: params[:branch_id]).first

    if @q.present?
      @insurance_loan_bundle_enrollments = @insurance_loan_bundle_enrollments.where(
        "upper(data->'records'->0->'member'->>'first_name') LIKE :q OR upper(data->'records'->0->'member'->>'last_name') LIKE :q",
        q: "%#{@q.upcase}%"
      )
    end

    if @branch.present?
      @insurance_loan_bundle_enrollments  = @insurance_loan_bundle_enrollments.where(branch_id: @branch.id)
    end

    if params[:start_date].present? and params[:end_date].present?
      @insurance_loan_bundle_enrollments = @insurance_loan_bundle_enrollments.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @insurance_loan_bundle_enrollments = @insurance_loan_bundle_enrollments.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @insurance_loan_bundle_enrollments = @insurance_loan_bundle_enrollments.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @insurance_loan_bundle_enrollments = @insurance_loan_bundle_enrollments.where(status: @status)
    end

    @insurance_loan_bundle_enrollments = @insurance_loan_bundle_enrollments.order("status DESC, collection_date DESC").page(params[:page]).per(100)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Insurance Loan Bundle Enrollments"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new-transaction",
        link: "#",
        class: "fa fa-plus",
        text: "New Transaction"
      }
    ]
  end

  def show
    @insurance_loan_bundle_enrollment  = InsuranceLoanBundleEnrollment.find(params[:id])

    if @insurance_loan_bundle_enrollment.processing?
      redirect_to insurance_loan_bundle_enrollments_path
    end

    if !Settings.activate_microinsurance
      @members  = Member.active.where(
                    center_id: @insurance_loan_bundle_enrollment.center.id
                  ).where.not(
                    id: @insurance_loan_bundle_enrollment.member_ids
                  ).order("last_name ASC")
    else
      @members  = Member.inforce_lapsed_resigned.where(
                    center_id: @insurance_loan_bundle_enrollment.center.id
                  ).where.not(
                    id: @insurance_loan_bundle_enrollment.member_ids
                  ).order("last_name ASC")
    end
    @kok_data = @insurance_loan_bundle_enrollment.data.with_indifferent_access[:kok_data]

    if @kok_data.present?
      @plan_type = @kok_data[:plan_type]
      @plan_category = @kok_data[:plan_category]
      @partner = @kok_data[:partner]
      @policy_no = @kok_data[:policy_no]
      @effectivity_date = @kok_data[:effectivity_date]
      @maturity_date = @effectivity_date.to_date == Date.today + 1.year
      @client_type = @kok_data[:client_type]
      @first_name = @kok_data[:first_name]
      @middle_name = @kok_data[:middle_name]
      @last_name = @kok_data[:last_name]
      @address = @kok_data[:address]
      @gender = @kok_data[:gender]
      @enrolled_status = @kok_data[:enrolled_status]
      @civil_status = @kok_data[:civil_status]
      @birth_date = @kok_data[:birth_date]
      @age[:age] = @age[:birth_date].present? ? Date.today.year - @kok_data[:birth_date].to_date.year : ""
      @premium_coverage = @kok_data[:premium_coverage]
      @mobile_no = @kok_data[:mobile_no]
      @membership_date = @kok_data[:membership_date]
      @benif_fname = @kok_data[:benif_fname]
      @benif_mname = @kok_data[:benif_mname]
      @benif_lname = @kok_data[:benif_lname]
      @benif_birth_date = @kok_data[:benif_birth_date]
      @benif_gender = @kok_data[:benif_gender]
      @benif_relationship = @kok_data[:benif_relationship]
    end

    if !Settings.activate_microinsurance
      @members  = Member.active.where(center_id: @insurance_loan_bundle_enrollment.center.id)
    else
      @members  = Member.inforce_lapsed_resigned.where(center_id: @insurance_loan_bundle_enrollment.center.id)
    end

    @records  = @insurance_loan_bundle_enrollment.data.with_indifferent_access["records"]

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: insurance_loan_bundle_enrollments_path,
        text: "Insurance Loan Bundles"
      },
      {
        text: "Record: #{@insurance_loan_bundle_enrollment.id}"
      }
    ]

    @subheader_side_actions = []

    if @insurance_loan_bundle_enrollment.pending?
      if ["OAS", "MIS", "REMOTE-MIS"].include? current_user.roles.last
        @subheader_side_actions << {
          id: "btn-print",
          class: "fa fa-print",
          text: "Print PDF",
          data: {
            id: "#{@insurance_loan_bundle_enrollment}"
          }
        }

        if @insurance_loan_bundle_enrollment.records_count > 0
            @subheader_side_actions << {
            id: "btn-check",
            link: "#",
            class: "fa fa-check",
            text: "For-Checking"
          }
        end

        @subheader_side_actions << {
              id: "btn-declined",
              link: "#",
              class: "fa fa-check",
              text: "Decline"
        }

        @subheader_side_actions << {
          link: insurance_loan_bundle_enrollment_path(@insurance_loan_bundle_enrollment.id),
          class: "fa fa-times",
          text: "Delete",
          data: { method: :delete, confirm: "Are you sure?" }
        }
      end
    end

    if @insurance_loan_bundle_enrollment.checked?
      if ["MIS", "FM", "CM", "REMOTE-MIS"].include? current_user.roles.last
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }
        @subheader_side_actions << {
            id: "btn-declined",
            link: "#",
            class: "fa fa-check",
            text: "Decline"
        }
      end
    end

    if (@insurance_loan_bundle_enrollment.for_renewal? ||  @insurance_loan_bundle_enrollment.on_grace_period?) && @insurance_loan_bundle_enrollment.records_last[:kok_data][:age] < 76
      if ["MIS", "BK", "SBK", "FM", "CM", "REMOTE-MIS"].include? current_user.roles.last
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }

        @subheader_side_actions << {
            id: "btn-declined",
            link: "#",
            class: "fa fa-check",
            text: "Decline"
        }
      end
    end

    @payload = {
      id: @insurance_loan_bundle_enrollment.id
    }
  end

  def destroy
    @insurance_loan_bundle_enrollment  = InsuranceLoanBundleEnrollment.find(params[:id])
    @insurance_loan_bundle_enrollment.destroy!

    redirect_to insurance_loan_bundle_enrollments_path
  end

  def upload
    file              = params[:file]
    collection_date   = params[:collection_date]
    prepared_by       = current_user

    config = {
      file: file,
      collection_date: collection_date,
      prepared_by: prepared_by
    }

    @errors_arr = []

    # Process each row in the file
    CSV.foreach(file.path, headers: true) do |row|
      # Validate each row
      errors = InsuranceLoanBundleEnrollments::ValidateLoanBundleEnrollmentsFromCsvFile.new(row: row).execute!

      if errors[:messages].any?
        @errors_arr << errors
      end
    end

    if @errors_arr.flatten.size > 20
      flash[:error] = ["Error, please check your csv."]
      redirect_to upload_loan_bundle_enrollments_path
    elsif @errors_arr.any?
      flash[:error] = @errors_arr.flatten
      redirect_to upload_loan_bundle_enrollments_path
    else
      # If no errors, proceed with loading the data
      @insurance_fund_transfer_collection = InsuranceLoanBundleEnrollments::LoadLoanBundleEnrollmentsFromCsvFile.new(config: config).execute!
      flash[:success] = "Successfully uploaded fund transfer."
      redirect_to insurance_loan_bundle_enrollments_path(@insurance_fund_transfer_collection)
    end
  end
end
