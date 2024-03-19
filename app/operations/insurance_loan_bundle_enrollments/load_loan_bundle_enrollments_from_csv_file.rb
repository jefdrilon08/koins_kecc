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
        @id                        = row['id']
        @member_full_name          = row['member_full_name']
        @member_fname              = row['member_fname']
        @member_lname              = row['member_lname']
        @member_mname              = row['member_mname']
        @effectivity_date          = row['effectivity_date']
        @client_type               = row['client_type']
        @first_name                = row['first_name']
        @middle_name               = row['middle_name']
        @last_name                 = row['last_name']
        @age                       = row['age']
        @gender                    = row['gender']
        @mobile_no                 = row['mobile_no']
        @address                   = row['address']
        @plan_type                 = row['plan_type']
        @partner                   = row['partner']
        @policy_no                 = row['policy_no']
        @benif_fname               = row['benif_fname']
        @benif_lname               = row['benif_lname']
        @benif_mname               = row['benif_mname']
        @benif_gender              = row['benif_gender']
        @benif_birth_date          = row['benif_birth_date']
        @benif_relationship        = row['benif_relationship']
        @maturity_date             = row['maturity_date']
        @plan_category             = row['plan_category']
        @enrolled_status           = row['enrolled_status']
        @membership_date           = row['membership_date']
        @effectivity_date          = row['effectivity_date']
        @premium_coverage          = row['premium_coverage']
        @full_name_dependent       = row['full_name_dependent']


        @insurance_loan_bundle_enrollments = ::InsuranceLoanBundleEnrollments::CreateInsuranceLoanBundleEnrollments.new(
          config: {
            collection_date: @collection_date,
            user: @prepared_by,
            branch_id: @branch_id,
            center_id: @center_id,
            id: @id,
            member_full_name: @member_full_name,
            member_fname: @member_fname,
            member_lname: @member_lname,
            member_mname: @member_mname,
            effectivity_date: @effectivity_date,
            client_type: @client_type,
            first_name: @first_name,
            middle_name: @middle_name,
            last_name: @last_name,
            age: @age,
            gender: @gender,
            mobile_no: @mobile_no,
            address: @address,
            plan_type: @plan_type,
            partner: @partner,
            policy_no: @policy_no,
            benif_fname: @benif_fname,
            benif_lname: @benif_lname,
            benif_mname: @benif_mname,
            benif_gender: @benif_gender,
            benif_birth_date: @benif_birth_date,
            benif_relationship: @benif_relationship,
            maturity_date: @maturity_date,
            plan_category: @plan_category,
            enrolled_status: @enrolled_status,
            membership_date: @membership_date,
            effectivity_date: @effectivity_date,
            premium_coverage: @premium_coverage,
            full_name_dependent: @full_name_dependent
          }
        ).execute!
      end
    end
  end
end  