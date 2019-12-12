module Members
  class ValidateImportLegalDependentsFromCsvFile < AppValidator
    def initialize(config:)
      super()

      @legal_dependent = config[:legal_dependent]
    end

    def execute!
      validate_if_member_present!
      validate_if_identification_number_present!
      validate_if_relationship_present!
      validate_if_uuid_present!
      validate_if_member_uuid_present!
      @errors
    end

    private

    def validate_if_member_present!
      member = Member.where(identification_number: @legal_dependent['member_identification_number']).first
      if member.nil?
        @errors[:messages] << {
          key: "member",
          message: "No member with identification_number #{@legal_dependent['member_identification_number']}"
        }
      end
    end

    def validate_if_identification_number_present!
      if @legal_dependent['member_identification_number'].nil?
        @errors[:messages] << {
          key: "identification_number",
          message: "Member Identification Number can't be blank."
        }
      end
    end

    def validate_if_relationship_present!
      if @legal_dependent['relationship'].nil?
        @errors[:messages] << {
          key: "relationship",
          message: "Relationship can't be blank."
        }
      end
    end

    def validate_if_uuid_present!
      if @legal_dependent['uuid'].nil?
        @errors[:messages] << {
          key: "uuid",
          message: "UUID can't be blank."
        } 
      end
    end

    def validate_if_member_uuid_present!
      if @legal_dependent['member_uuid'].nil?
        @errors[:messages] << {
          key: "member_uuid",
          message: "Member UUID can't be blank."
        } 
      end
    end
  end
end