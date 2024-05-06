module InsuranceLoanBundleEnrollments
  class MemberRenewal
    def initialize(config:)
      @config                                  = config
      @insurance_loan_bundle_enrollment        = @config[:insurance_loan_bundle_enrollment]
      @insurance_loan_bundle_enrollment_data   = @insurance_loan_bundle_enrollment.data.with_indifferent_access
      @insurance_loan_bundle_enrollment_count  = @insurance_loan_bundle_enrollment_data[:records].count
      @user                                    = @config[:user]
      @member                                  = @config[:member]

      @last_kok_data_records        = @insurance_loan_bundle_enrollment_data[:records].last
      @last_effectivity_date        = @last_kok_data_records[:kok_data][:effectivity_date]
      @previous_client_type         = @last_kok_data_records[:kok_data][:client_type]
      @previous_plan_type           = @last_kok_data_records[:kok_data][:plan_type]
      @previous_plan_category       = @last_kok_data_records[:kok_data][:plan_category]
      @previous_partner             = @last_kok_data_records[:kok_data][:partner]
      @previous_policy_no           = @last_kok_data_records[:kok_data][:policy_no]
      @last_membership_date         = @last_kok_data_records[:kok_data][:membership_date]
      @prevoius_member              = @last_kok_data_records[:member]
      @prevoius_member_id           = @last_kok_data_records[:member][:id]
      @prevoius_member_first_name   = @last_kok_data_records[:member][:first_name]
      @prevoius_member_middle_name  = @last_kok_data_records[:member][:middle_name]
      @prevoius_member_last_name    = @last_kok_data_records[:member][:last_name]
      @previous_age                 = @last_kok_data_records[:kok_data][:age].to_i
      @previous_gender              = @last_kok_data_records[:kok_data][:gender]
      @previous_address             = @last_kok_data_records[:kok_data][:address]
      @previous_last_name           = @last_kok_data_records[:kok_data][:last_name]
      @previous_middle_name         = @last_kok_data_records[:kok_data][:middle_name]
      @previous_first_name          = @last_kok_data_records[:kok_data][:first_name]
      @previous_mobile_no           = @last_kok_data_records[:kok_data][:mobile_no]
      @previous_birth_date          = @last_kok_data_records[:kok_data][:birth_date]
      @previous_civil_status        = @last_kok_data_records[:kok_data][:civil_status]
      @previous_full_name           = @last_kok_data_records[:kok_data][:full_name]
      @previous_age                 = ((@last_effectivity_date.to_time - @previous_birth_date.to_time)/(60*60*24*365)).floor(4)


      @maturity_date                          = @last_effectivity_date.to_date + 2.year
      @effectivity_date                       = @last_effectivity_date.to_date + 1.year
      @enrolled_status                        = "RENEWAL"
      @plan_type                              = @previous_plan_type
      @plan_category                          = @previous_plan_category
      @client_type                            = @previous_client_type
      @partner                                = @previous_partner
      @policy_no                              = @previous_policy_no
      @membership_date                        = @last_membership_date
      @member                                 = @prevoius_member
      @first_name                             = @previous_first_name
      @middle_name                            = @previous_middle_name
      @last_name                              = @previous_last_name
      @full_name                              = @previous_full_name
      @address                                = @previous_address
      @gender                                 = @previous_gender
      @birth_date                             = @previous_birth_date
      @mobile_no                              = @previous_mobile_no
      @civil_status                           = @previous_civil_status
      @age                                    = ((@effectivity_date.to_time - @birth_date.to_time)/(60*60*24*365)).floor(4)

      if @age >= 18 && @age < 66
        @premium_coverage                     = 550
      else
        @premium_coverage                     = 1475
      end

      @benif_fname                            = @config[:benif_fname]
      @benif_mname                            = @config[:benif_mname]
      @benif_lname                            = @config[:benif_lname]
      @benif_birth_date                       = @config[:benif_birth_date]
      @benif_gender                           = @config[:benif_gender]
      @benif_relationship                     = @config[:benif_relationship]
      @data                                   = @insurance_loan_bundle_enrollment.try(:data).try(:with_indifferent_access)
      @branch                                 = @insurance_loan_bundle_enrollment.branch
    end

    def execute!
      if @insurance_loan_bundle_enrollment_count == 0
        @data[:records] << {
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          full_name: @full_name

        },
        kok_data: {
          plan_type: @plan_type,
          plan_category: @plan_category,
          partner: @partner,
          policy_no: @policy_no,
          effectivity_date: @effectivity_date,
          maturity_date: @maturity_date,
          client_type: @client_type,
          first_name: @first_name,
          middle_name: @middle_name,
          last_name: @last_name,
          full_name: @full_name,
          full_name_dependent: @full_name_dependent,
          address: @address,
          gender: @gender,
          enrolled_status: @enrolled_status,
          civil_status: @civil_status,
          birth_date: @birth_date,
          age: @age,
          premium_coverage: @premium_coverage,
          mobile_no: @mobile_no,
          membership_date: @membership_date,
          benif_fname: @benif_fname,
          benif_mname: @benif_mname,
          benif_lname: @benif_lname,
          benif_birth_date: @benif_birth_date,
          benif_gender: @benif_gender,
          benif_relationship: @benif_relationship
        },
      }
      else
        @data[:records] << {
        member: {
          id: @prevoius_member_id,
          first_name: @prevoius_member_first_name,
          middle_name: @prevoius_member_middle_name,
          last_name: @prevoius_member_last_name,
          full_name: @previous_full_name

        },
        kok_data: {
          plan_type: @plan_type,
          plan_category: @plan_category,
          partner: @partner,
          policy_no: @policy_no,
          effectivity_date: @effectivity_date,
          maturity_date: @maturity_date,
          client_type: @client_type,
          first_name: @first_name,
          middle_name: @middle_name,
          last_name: @last_name,
          full_name: @full_name,
          full_name_dependent: @full_name_dependent,
          address: @address,
          gender: @gender,
          enrolled_status: @enrolled_status,
          civil_status: @civil_status,
          birth_date: @birth_date,
          age: @age,
          premium_coverage: @premium_coverage,
          mobile_no: @mobile_no,
          membership_date: @membership_date,
          benif_fname: @benif_fname,
          benif_mname: @benif_mname,
          benif_lname: @benif_lname,
          benif_birth_date: @benif_birth_date,
          benif_gender: @benif_gender,
          benif_relationship: @benif_relationship
        },
      }
      end

      @insurance_loan_bundle_enrollment.update!(data: @data)
      @insurance_loan_bundle_enrollment.update!(status: "for-renewal")
      @insurance_loan_bundle_enrollment
    end
  end
end
