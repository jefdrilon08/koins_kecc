module InsuranceLoanBundleEnrollments
  class ValidateRemoveMember < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @insurance_loan_bundle_enrollment  = @config[:insurance_loan_bundle_enrollment]
      @member                                 = @config[:member]

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

      if @member.present? and !@insurance_loan_bundle_enrollment.member_ids.include?(@member.id)
        @errors[:messages] << {
          key: "message",
          message: "Member not found"
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
