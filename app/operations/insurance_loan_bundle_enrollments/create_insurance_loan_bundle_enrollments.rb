module InsuranceLoanBundleEnrollments
  class CreateInsuranceLoanBundleEnrollments
    def initialize(config:)
      @config                               = config
      @collection_date                      = @config[:collection_date].try(:to_date)
      @user                                 = @config[:user]
      @branch                               = Branch.where(id: @config[:branch_id]).first
      @center                               = Center.where(id: @config[:center_id]).first


      # raise @config[:member_lname].inspect
      @insurance_loan_bundle_enrollments = InsuranceLoanBundleEnrollment.new(
        branch: @branch,
        center: @center,
        collection_date: @collection_date
      )

      @data = {
        records: [
          member: {
            id: @config[:member_id],
            full_name: @config[:full_name],
            first_name: @config[:last_name],
            last_name: @config[:first_name],
            middle_name: @config[:middle_name],
            effectivity_date: @effectivity_date
          },
          kok_data: {
            age: @config[:age],
            gender: @config[:gender],
            address: @config[:address],
            partner: @config[:partner],
            full_name: @config[:full_name] ,
            last_name: @config[:last_name],
            mobile_no: @config[:mobile_no],
            plan_type: @config[:plan_type],
            policy_no: @config[:policy_no],
            birth_date: @config[:birth_date],
            first_name: @config[:first_name],
            benif_fname: @config[:benif_fname],
            benif_lname: @config[:benif_lname],
            benif_mname: @config[:benif_mname],
            client_type: @config[:client_type],
            middle_name: @config[:middle_name],
            benif_gender: @config[:benif_gender],
            civil_status: @config[:civil_status],
            maturity_date: @config[:maturity_date],
            plan_category: @config[:plan_category],
            enrolled_status: @config[:enrolled_status],
            membership_date: @config[:membership_date],
            benif_birth_date: @config[:benif_birth_date],
            effectivity_date: @config[:effectivity_date],
            premium_coverage: @config[:premium_coverage],
            benif_relationship: @config[:benif_relationship],
            full_name_dependent: @config[:full_name_dependent]
          }
        ]
      }
    end

    def execute!
      @insurance_loan_bundle_enrollments.data = @data
      @insurance_loan_bundle_enrollments.update!(status: "approved")
      @insurance_loan_bundle_enrollments.save!
      @insurance_loan_bundle_enrollments
    end
  end
end
