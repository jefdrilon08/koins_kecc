module DepositCollections
  class ValidateDepositFromCsvFile < AppValidator
    def initialize(deposit_collection:, config:)
      super()
      @config             = config
      @deposit_collection = deposit_collection
      @paid_at            = @config[:paid_at]
      @branch             = @config[:branch]
    end

    def execute!
      check_if_identification_number_present!
      check_if_identification_number_valid!
      check_if_insurance_types_present!
      check_if_branch_present!
      check_if_paid_at_present!   
      @errors
    end

    private

    def check_if_identification_number_valid!
      member = Member.where(identification_number: @deposit_collection['identification_number']).first
      if member.nil?
        @errors[:messages] << {
          key: "member",
          message: "No Member with Identification Number: #{@deposit_collection['identification_number']}. "
        }
      end
    end

    def check_if_identification_number_present!
      if @deposit_collection['identification_number'].nil?
        @errors[:messages] << {
          key: "identification_number",
          message: "ID can't be blank. "
        }
      end
    end

    def check_if_insurance_types_present!
      if @deposit_collection['RF'].nil?
        @errors[:messages] << {
          key: "rf",
          message: "Retirement Fund can't be blank for #{@deposit_collection['Member']}. "
        }
      end

      if @deposit_collection['LIF'].nil?
        @errors[:messages] << {
          key: "lif",
          message: "Life Fund can't be blank for #{@deposit_collection['Member']}. "
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

    def check_if_paid_at_present!
      if @paid_at.nil?
        @errors[:messages] << {
          key: "paid_at",
          message: "Date of deposit cant be blank. "
        }
      end
    end
  end
end