module InsuranceLoanBundleEnrollments
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                                   = config
      @insurance_loan_bundle_enrollment         = @config[:insurance_loan_bundle_enrollment]
      @insurance_loan_bundle_enrollment_data    = @insurance_loan_bundle_enrollment.data.with_indifferent_access
      @insurance_loan_bundle_enrollment_count   = @insurance_loan_bundle_enrollment_data[:records].count
      if @insurance_loan_bundle_enrollment_count == 0
        @last_effectivity_date      = @config[:effectivity_date]
        @previous_plan_type         = @config[:plan_type]
        @previous_plan_category     = @config[:plan_category]
        @previous_client_type       = @config[:client_type]
        @previous_partner           = @config[:partner]
        @previous_policy_no         = @config[:policy_no]
        @last_membership_date       = @config[:membership_date]
        @prevoius_member            = @config[:member]
        # raise @previous_client_type.inspect

        if @previous_client_type == "DEPENDENT"
                          
          @previous_gender  = @config[:gender]
          @previous_address = @config[:address]
          # @previous_full_name = @member.full_name_formatted
          # raise @previous_full_name.inspect
          @previous_last_name = @config[:last_name]
          @previous_middle_name = @config[:middle_name]
          @previous_first_name = @config[:first_name]
          @previous_full_name_dependent = @config[:first_name] + ' ' + @config[:middle_name] + '. ' + @config[:last_name]
          @previous_mobile_no = @config[:mobile_no]
          @previous_birth_date = @config[:birth_date]
          @previous_civil_status = @config[:civil_status]
          # @previous_benif_fname = @config[:benif_fname]
          # @previous_benif_lname = @config[:benif_lname]
          # @previous_benif_mname = @config[:benif_mname]
          # @previous_benif_gender = @config[:benif_gender]
          # @previous_benif_birth_date  = @config[:benif_birth_date]
          # @previous_benif_relationship  = @config[:benif_relationship]
        else
          
          # raise @previous_client_type.inspect
          @previous_first_name                             = @prevoius_member.first_name
          @previous_middle_name                            = @prevoius_member.middle_name
          @previous_last_name                              = @prevoius_member.last_name
          @previous_address                                = @prevoius_member.full_address_upcase
          @previous_full_name                              = @prevoius_member.full_name_formatted
          @previous_gender                                 = @prevoius_member.gender
          @previous_birth_date                             = @prevoius_member.date_of_birth
          @previous_mobile_no                              = @prevoius_member.mobile_number
          @previous_civil_status                           = @prevoius_member.civil_status
          # @previous_benif_fname = @config[:benif_fname]
          # @previous_benif_lname = @config[:benif_lname]
          # @previous_benif_mname = @config[:benif_mname]
          # @previous_benif_gender = @config[:benif_gender]
          # @previous_benif_birth_date  = @config[:benif_birth_date]
          # @previous_benif_relationship  = @config[:benif_relationship]
        end
      else
        @last_kok_data_records     = @insurance_loan_bundle_enrollment_data[:records].last
        @last_effectivity_date     = @last_kok_data_records[:kok_data][:effectivity_date]
        @previous_client_type      = @last_kok_data_records[:kok_data][:client_type]
        @previous_plan_type        = @last_kok_data_records[:kok_data][:plan_type]
        @previous_plan_category    = @last_kok_data_records[:kok_data][:plan_category]
        @previous_partner          = @last_kok_data_records[:kok_data][:partner]
        @previous_policy_no        = @last_kok_data_records[:kok_data][:policy_no]
        @last_membership_date      = @last_kok_data_records[:kok_data][:membership_date]
        @prevoius_member           = @last_kok_data_records[:member]
        @previous_age              = @last_kok_data_records[:kok_data][:age].to_i
        @previous_gender           = @last_kok_data_records[:kok_data][:gender]
        @previous_address          = @last_kok_data_records[:kok_data][:address]
        @previous_last_name        = @last_kok_data_records[:kok_data][:last_name]
        @previous_middle_name      = @last_kok_data_records[:kok_data][:middle_name]
        @previous_first_name       = @last_kok_data_records[:kok_data][:first_name]
        @previous_mobile_no = @last_kok_data_records[:kok_data][:mobile_no]
        @previous_birth_date  = @last_kok_data_records[:kok_data][:birth_date]
        @previous_civil_status = @last_kok_data_records[:kok_data][:civil_status]
        if @previous_client_type == "DEPENDENT"
          @previous_full_name_dependent = @last_kok_data_records[:kok_data][:full_name_dependent]
          @previous_full_name = @last_kok_data_records[:kok_data][:full_name]
        else
          @previous_full_name = @last_kok_data_records[:kok_data][:full_name]
        end
      end
        
      if @insurance_loan_bundle_enrollment_count == 0
        @effectivity_date                       = @config[:effectivity_date]
        @maturity_date                          = @config[:effectivity_date].to_date + 1.year
        # raise @maturity_date.inspect
        @enrolled_status                        = "NEW"
        @plan_type                              = @config[:plan_type]  
        @plan_category                          = @config[:plan_category]
        @client_type                            = @config[:client_type]
        @partner                                = @config[:partner]
        @policy_no                              = @config[:policy_no]
        @membership_date                        = @config[:membership_date]
        @member                                 = @config[:member]
        if @client_type == "DEPENDENT"
          @first_name                             = @config[:first_name]
          @middle_name                            = @config[:middle_name]
          @last_name                              = @config[:last_name]
          @full_name_dependent                    = @config[:first_name] + ' ' + @config[:middle_name] + '. ' + @config[:last_name]
          @full_name                              = @member.full_name_formatted
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
          @full_name                              = @member.full_name_formatted
          @gender                                 = @member.gender
          @birth_date                             = @member.date_of_birth
          @mobile_no                              = @member.mobile_number
          @civil_status                           = @member.civil_status
        end
        @age                = ((@effectivity_date.to_time - @birth_date.to_time)/(60*60*24*365)).floor(4)
        
      else
        @maturity_date                          = @last_effectivity_date.to_date + 2.year
        @effectivity_date                       = (@last_effectivity_date.to_date + 1.year)
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
        if @client_type == 'DEPENDENT'
          @full_name_dependent                    = @previous_full_name_dependent
          @full_name                              = @previous_full_name
        else
          @full_name                              = @previous_full_name
        end
        @address                                = @previous_address
        @gender                                 = @previous_gender
        @birth_date                             = @previous_birth_date
        @mobile_no                              = @previous_mobile_no
        @civil_status                           = @previous_civil_status
        @age                = ((@last_effectivity_date.to_time - @previous_birth_date.to_time)/(60*60*24*365)).floor(4)
      end
      
      
      
      @premium_coverage   = @config[:premium_coverage]
      
      @benif_fname        = @config[:benif_fname]
      @benif_mname        = @config[:benif_mname]
      @benif_lname        = @config[:benif_lname]
      @benif_birth_date   = @config[:benif_birth_date]
      @benif_gender       = @config[:benif_gender]
      @benif_relationship = @config[:benif_relationship]

      @data = @insurance_loan_bundle_enrollment.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @insurance_loan_bundle_enrollment.present? and !@insurance_loan_bundle_enrollment.pending?
        @errors[:messages] << {
          key: "insurance_loan_bundle_enrollment",
          message: "record is not pending"
        }
      end
      
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member required"
        }
      end

      # if @member.present? and @insurance_loan_bundle_enrollment.member_ids.include?(@member.id)
      #   @errors[:messages] << {
      #     key: "message",
      #     message: "Member already included"
      #   }
      # end

      if @client_type = "DEPENDENT" and @gender.blank?
        @errors[:messages] << {
          key: "gender",
          message: "Please Select Gender"
        }
      end  

      if @client_type = "DEPENDENT" and @civil_status.blank?
        @errors[:messages] << {
          key: "gender",
          message: "Please Select Civil Status"
        }
      end  


      if @age < 18 
        @errors[:messages] << {
          key: "age",
          message: "You should be 18 yrs old and above"
        }
      end

      if @age >= 76
        @errors[:messages] << {
          key: "age",
          message: "You should be below 76 yrs old"
        }
      end

      if @enrolled_status == "RENEWAL" && @age < 18
        @errors[:messages] << {
          key: "age",
          message: "Your age is not qualified for Renewal."
        }
      end

      if @enrolled_status == "RENEWAL" && @age > 75
        @errors[:messages] << {
          key: "age",
          message: "Your age is not qualified for Renewal."
        }
      end

      if @enrolled_status == "NEW" && @age < 18
        @errors[:messages] << {
          key: "age",
          message: "Your age is not qualified."
        }
      end

      if @enrolled_status == "NEW" && @age > 70
        @errors[:messages] << {
          key: "age",
          message: "Your age is not qualified."
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end