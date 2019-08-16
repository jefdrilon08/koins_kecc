module Members
  class ValidateImportBeneficiariesFromCsvFile < AppValidator
    def initialize(config:)
      super()

      @beneficiary = config[:beneficiary]
    end

    def execute!
      validate_if_member_present!
      validate_if_identification_number_present!
      validate_if_uuid_present!
      @errors
    end

    private

    def validate_if_member_present!
      member = Member.where(identification_number: @beneficiary['member_identification_number']).first
      if member.nil?
        @errors[:messages] << {
          key: "member",
          message: "No member with identification_number #{@beneficiary['member_identification_number']}"
        }
      end
    end

    def validate_if_identification_number_present!
      if @beneficiary['member_identification_number'].nil?
        @errors[:messages] << {
          key: "identification_number",
          message: "Member Identification Number can't be blank."
        }
      end
    end

    def validate_if_uuid_present!
      if @beneficiary['uuid'].nil?
        @errors[:messages] << {
          key: "uuid",
          message: "UUID can't be blank."
        } 
      end
    end
  end
end