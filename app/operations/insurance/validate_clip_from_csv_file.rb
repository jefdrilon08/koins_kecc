module Insurance
  class ValidateClipFromCsvFile < AppValidator
    def initialize(clip:, branch:)
      super()
      @branch = branch
      @clip   = clip
    end

    def execute!
      check_if_identification_number_present!
      check_if_identification_number_valid!
      # check_if_branch_present!
      @errors
    end

    private

    def check_if_identification_number_valid!
      member = Member.where(identification_number: @clip['identification_number']).first
      if member.nil?
        @errors[:messages] << {
          key: "member",
          message: "No Member with Identification Number: #{@insurance_withdrawal_collection['identification_number']}. "
        }
      end
    end

    def check_if_identification_number_present!
      if @clip['identification_number'].nil?
        @errors[:messages] << {
          key: "identification_number",
          message: "ID can't be blank. "
        }
      end
    end

    def check_if_branch_present!
      if @branch.nil?
        @errors[:messages] << {
          key: "branch",
          message: "Branch cant be blank. "
        }
      end
    end
  end
end