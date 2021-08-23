module InsuranceWithdrawalCollections
  class ValidateInsuranceWithdrawalFromCsvFile < AppValidator
    def initialize(insurance_withdrawal_collection:, config:)
      super()
      @config                              = config
      @insurance_withdrawal_collection     = insurance_withdrawal_collection
      @paid_at                             = @config[:paid_at]
      @branch                              = @config[:branch]
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
      member = Member.where(identification_number: @insurance_withdrawal_collection['identification_number']).first
      if member.nil?
        @errors[:messages] << {
          key: "member",
          message: "No Member with Identification Number: #{@insurance_withdrawal_collection['identification_number']}. "
        }
      end
    end

    def check_if_identification_number_present!
      if @insurance_withdrawal_collection['identification_number'].nil?
        @errors[:messages] << {
          key: "identification_number",
          message: "ID can't be blank. "
        }
      end
    end

    def check_if_insurance_types_present!
      if @insurance_withdrawal_collection['RF'].nil?
        @errors[:messages] << {
          key: "rf",
          message: "Retirement Fund can't be blank for #{@insurance_withdrawal_collection['Member']}. "
        }
      end

      if @insurance_withdrawal_collection['LIF'].nil?
        @errors[:messages] << {
          key: "lif",
          message: "Life Fund can't be blank for #{@insurance_withdrawal_collection['Member']}. "
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