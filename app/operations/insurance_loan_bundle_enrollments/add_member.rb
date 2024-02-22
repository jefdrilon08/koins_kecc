module InsuranceLoanBundleEnrollments
  class AddMember
    def initialize(config:)
      @config                                 = config
      @insurance_loan_bundle_enrollment       = @config[:insurance_loan_bundle_enrollment]
      @member                                 = @config[:member]
      @user                                   = @config[:user]
      @plan_type                              = @config[:plan_type]
      @client_type                            = @config[:client_type]
      
      if @client_type == "DEPENDENT"
        @first_name                             = @config[:first_name]
        @middle_name                            = @config[:middle_name]
        @last_name                              = @config[:last_name]
        @address                                = @config[:address]
        @gender                                 = @config[:gender]
        @birth_date                             = @config[:birth_date]
        @mobile_no                              = @config[:mobile_no]
        @civil_status                           = @config[:civil_status]        
      else
        @first_name                             = @member.first_name
        @middle_name                            = @member.middle_name
        @last_name                              = @member.last_name
        @address                                = @member.full_address_upcase
        @gender                                 = @member.gender
        @birth_date                             = @member.date_of_birth
        @mobile_no                              = @member.mobile_number
        @civil_status                           = @member.civil_status
      end

      @plan_category                          = @config[:plan_category]
      @partner                                = @config[:partner]
      @policy_no                              = @config[:policy_no]
      @effectivity_date                       = @config[:effectivity_date]
      @maturity_date                          = (@effectivity_date.to_date + 1.year) 
      @enrolled_status                        = @config[:enrolled_status]
      @age                                    = ((@effectivity_date.to_time - @birth_date.to_time)/(60*60*24*365)).floor(4)
      
      if @age >= 18 && @age < 66
        @premium_coverage                     = 550
      else 
        @premium_coverage                     = 1475   
      end
     
      @membership_date                        = @config[:membership_date]
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
      
      @data[:records] << {
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name
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
     
      @insurance_loan_bundle_enrollment.update!(data: @data)

      @insurance_loan_bundle_enrollment


    end
  end
end