module KpfLoanClips
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                                   = config
      @kpf_loan_clip         = @config[:kpf_loan_clip]
      @kpf_loan_clip_data    = @kpf_loan_clip.data.with_indifferent_access
      @kpf_loan_clip_count   = @kpf_loan_clip_data[:records].count
      @member                = @config[:member]
      # if @kpf_loan_clip_count == 0
      #   @last_effectivity_date      = @config[:effectivity_date]
      #   @previous_plan_type         = @config[:plan_type]
      #   @previous_plan_category     = @config[:plan_category]
      #   @previous_client_type       = @config[:client_type]
      #   @previous_partner           = @config[:partner]
      #   @previous_policy_no         = @config[:policy_no]
      #   @prevoius_member            = @config[:member]
      #   @previous_first_name        = @prevoius_member.first_name
      #   @previous_middle_name       = @prevoius_member.middle_name
      #   @previous_last_name         = @prevoius_member.last_name
      #   @previous_address           = @prevoius_member.full_address
      #   @previous_full_name         = @prevoius_member.full_name_formatted
      #   @previous_gender            = @prevoius_member.gender
      #   @previous_birth_date        = @prevoius_member.date_of_birth
      #   @previous_mobile_no         = @prevoius_member.mobile_number
      #   @previous_civil_status      = @prevoius_member.civil_status
      #   @last_membership_date       = @prevoius_member.date_of_membership
  
      # else
      #   @last_kok_data_records     = @kpf_loan_clip_data[:records].last
      #   @last_effectivity_date     = @last_kok_data_records[:kok_data][:effectivity_date]
      #   @previous_client_type      = @last_kok_data_records[:kok_data][:client_type]
      #   @previous_plan_type        = @last_kok_data_records[:kok_data][:plan_type]
      #   @previous_plan_category    = @last_kok_data_records[:kok_data][:plan_category]
      #   @previous_partner          = @last_kok_data_records[:kok_data][:partner]
      #   @previous_policy_no        = @last_kok_data_records[:kok_data][:policy_no]
      #   @last_membership_date      = @last_kok_data_records[:kok_data][:membership_date]
      #   @prevoius_member           = @last_kok_data_records[:member]
      #   @previous_age              = @last_kok_data_records[:kok_data][:age].to_i
      #   @previous_gender           = @last_kok_data_records[:kok_data][:gender]
      #   @previous_address          = @last_kok_data_records[:kok_data][:address]
      #   @previous_last_name        = @last_kok_data_records[:kok_data][:last_name]
      #   @previous_middle_name      = @last_kok_data_records[:kok_data][:middle_name]
      #   @previous_first_name       = @last_kok_data_records[:kok_data][:first_name]
      #   @previous_mobile_no        = @last_kok_data_records[:kok_data][:mobile_no]
      #   @previous_birth_date       = @last_kok_data_records[:kok_data][:birth_date]
      #   @previous_civil_status     = @last_kok_data_records[:kok_data][:civil_status]
      #   @previous_full_name        = @last_kok_data_records[:kok_data][:full_name]
        
      # end
        
      # if @kpf_loan_clip_count == 0
      #   @effectivity_date                       = @config[:effectivity_date]
      #   @maturity_date                          = @config[:effectivity_date].to_date + 1.year
      #   @enrolled_status                        = "NEW"
      #   @plan_type                              = @config[:plan_type]  
      #   @plan_category                          = @config[:plan_category]
      #   @client_type                            = @config[:client_type]
      #   @partner                                = @config[:partner]
      #   @policy_no                              = @config[:policy_no]
      #   @member                                 = @config[:member]
      #   @first_name                             = @member.first_name
      #   @middle_name                            = @member.middle_name
      #   @last_name                              = @member.last_name
      #   @address                                = @member.full_address
      #   @full_name                              = @member.full_name_formatted
      #   @gender                                 = @member.gender
      #   @birth_date                             = @member.date_of_birth
      #   @mobile_no                              = @member.mobile_number
      #   @civil_status                           = @member.civil_status
      #   @membership_date                        = @member.date_of_membership
      #   @age                = ((@effectivity_date.to_time - @birth_date.to_time)/(60*60*24*365.25)).floor(4)
        
      # else
      #   @maturity_date                          = @last_effectivity_date.to_date + 2.year
      #   @effectivity_date                       = (@last_effectivity_date.to_date + 1.year)
      #   @enrolled_status                        = "RENEWAL"
      #   @plan_type                              = @previous_plan_type
      #   @plan_category                          = @previous_plan_category
      #   @client_type                            = @previous_client_type
      #   @partner                                = @previous_partner
      #   @policy_no                              = @previous_policy_no
      #   @membership_date                        = @last_membership_date
      #   @member                                 = @prevoius_member
      #   @first_name                             = @previous_first_name
      #   @middle_name                            = @previous_middle_name
      #   @last_name                              = @previous_last_name
      #   @full_name                              = @previous_full_name
      #   @address                                = @previous_address
      #   @gender                                 = @previous_gender
      #   @birth_date                             = @previous_birth_date
      #   @mobile_no                              = @previous_mobile_no
      #   @civil_status                           = @previous_civil_status
      #   @age                = ((@last_effectivity_date.to_time - @previous_birth_date.to_time)/(60*60*24*365.25)).floor(4)
      # end
      
      
      
      # @premium_coverage   = @config[:premium_coverage]
      
      # @benif_fname        = @config[:benif_fname]
      # @benif_mname        = @config[:benif_mname]
      # @benif_lname        = @config[:benif_lname]
      # @benif_birth_date   = @config[:benif_birth_date]
      # @benif_gender       = @config[:benif_gender]
      # @benif_relationship = @config[:benif_relationship]

      @data = @kpf_loan_clip.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @kpf_loan_clip.present? and !@kpf_loan_clip.pending?
        @errors[:messages] << {
          key: "kpf_loan_clip",
          message: "record is not pending"
        }
      end
      
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member required"
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