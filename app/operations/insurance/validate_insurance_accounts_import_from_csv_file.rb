module Insurance
  class ValidateInsuranceAccountsImportFromCsvFile < AppValidator
    def initialize(config:)
      super()

      @insurance_account = config[:insurance_account]
    end

    def execute!
      check_if_parameters_present!
      @errors
    end

    private

    def check_if_parameters_present!
      if @insurance_account['insurance_type'].nil?
        @errors[:messages] << {
          key: "insurance_type",
          message: "Insurance Type can't be blank."
        }
      end      

      if @insurance_account['member_id'].nil?
        @errors[:messages] << {
          key: "member_id",
          message: "Member ID can't be blank."
        }
      end

      if @insurance_account['status'].nil?
        @errors[:messages] << {
          key: "status",
          message: "Status can't be blank."
        }
      end

      if @insurance_account['uuid'].nil?
         @errors[:messages] << {
          key: "uuid",
          message: "UUID can't be blank."
        }
      end
    end
  end
end
