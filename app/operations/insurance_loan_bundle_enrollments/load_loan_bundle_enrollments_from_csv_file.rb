module InsuranceLoanBundleEnrollments
  class LoadLoanBundleEnrollmentsFromCsvFile
    def initialize(config:)
      @config               = config
      @file                 = @config[:file]
      @prepared_by          = @config[:prepared_by]
      @collection_date      = @config[:collection_date]
    end

    def execute!
      CSV.foreach(@file.path, headers: true) do |row|
        @branch_id                 = row['branch_id']
        @center_id                 = row['center_id']
        @member_id                 = row['member_id']
        @full_name                 = row['full_name']
        @last_name                 = row['last_name']
        @first_name                = row['first_name']
        @middle_name               = row['middle_name']
        @effectivity_date          = row['effectivity_date']
        @age                       = row['age']
        @gender                    = row['gender']
        @address                   = row['address']
        @partner                   = row['partner']
        @mobile_no                 = row['mobile_no']
        @plan_type                 = row['plan_type']
        @policy_no                 = row['policy_no']
        @birth_date                = row['birth_date']
        @benif_fname               = row['benif_fname']
        @benif_lname               = row['benif_lname']
        @benif_mname               = row['benif_mname']
        @client_type               = row['client_type']
        @benif_gender              = row['benif_gender']
        @civil_status              = row['civil_status']
        @maturity_date             = row['maturity_date']
        @plan_category             = row['plan_category']
        @enrolled_status           = row['enrolled_status']
        @membership_date           = row['membership_date']
        @benif_birth_date          = row['benif_birth_date']
        @effectivity_date          = row['effectivity_date']
        @premium_coverage          = row['premium_coverage']
        @benif_relationship        = row['benif_relationship']
        @full_name_dependent       = row['full_name_dependent']


        @insurance_loan_bundle_enrollments = ::InsuranceLoanBundleEnrollments::CreateInsuranceLoanBundleEnrollments.new(
          config: {
            collection_date: @collection_date,
            user: @prepared_by,
            branch_id: @branch_id,
            center_id: @center_id,
            member_id: @member_id,
            full_name: @full_name,
            last_name: @last_name,
            first_name: @first_name,
            middle_name: @middle_name,
            effectivity_date: @effectivity_date,
            age: @age,
            gender: @gender,
            address: @address,
            partner: @partner,
            mobile_no: @mobile_no,
            plan_type: @plan_type,
            policy_no: @policy_no,
            birth_date: @birth_date,
            benif_fname: @benif_fname,
            benif_lname: @benif_lname,
            benif_mname: @benif_mname,
            client_type: @client_type,
            benif_gender: @benif_gender,
            civil_status: @civil_status,
            maturity_date: @maturity_date,
            plan_category: @plan_category,
            enrolled_status: @enrolled_status,
            membership_date: @membership_date,
            benif_birth_date: @benif_birth_date,
            effectivity_date: @effectivity_date,
            premium_coverage: @premium_coverage,
            benif_relationship: @benif_relationship,
            full_name_dependent: @full_name_dependent
          }
        ).execute!
      end
    end
  end
end
