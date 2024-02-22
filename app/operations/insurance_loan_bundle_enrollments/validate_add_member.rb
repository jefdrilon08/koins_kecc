module InsuranceLoanBundleEnrollments
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @insurance_loan_bundle_enrollment       = @config[:insurance_loan_bundle_enrollment]
      @member                                 = @config[:member]

      @plan_type          = @config[:plan_type]
      @plan_category      = @config[:plan_category]
      @partner            = @config[:partner]
      @policy_no          = @config[:policy_no]
      @effectivity_date   = @config[:effectivity_date]
      # @maturity_date      = @config[:maturity_date]
      @maturity_date      = @effectivity_date.to_date + 1.year

      # raise @maturity_date.inspect
      @client_type        = @config[:client_type]
      @first_name         = @config[:first_name]
      @middle_name        = @config[:middle_name]
      @last_name          = @config[:last_name]
      @birth_date         = @config[:birth_date]
      # raise @birth_date.inspect

      @age                = ((@effectivity_date.to_time - @birth_date.to_time)/(60*60*24*365)).floor(4)
      @address            = @config[:address]
      @gender             = @config[:gender]
      @enrolled_status    = @config[:enrolled_status]
      @civil_status       = @config[:civil_status]
      
      @premium_coverage   = @config[:premium_coverage]
      @mobile_no          = @config[:mobile_no]
      @membership_date    = @config[:membership_date]
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

      if @member.present? and @insurance_loan_bundle_enrollment.member_ids.include?(@member.id)
        @errors[:messages] << {
          key: "message",
          message: "Member already included"
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