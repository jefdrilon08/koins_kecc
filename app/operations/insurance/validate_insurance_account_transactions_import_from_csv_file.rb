module Insurance
  class ValidateInsuranceAccountTransactionsImportFromCsvFile < AppValidator
    def initialize(config:)
      super()

      @insurance_account_transaction = config[:insurance_account_transaction]
    end

    def execute!
      check_if_parameters_present!
      @errors
    end

    private

    def check_if_parameters_present!
      if @insurance_account_transaction['insurance_account_uuid'].nil?
        @errors[:messages] << {
          key: "insurance_account_uuid",
          message: "Insurance Account UUID can't be blank."
        }
      end 

      if @insurance_account_transaction['uuid'].nil?
        @errors[:messages] << {
          key: "uuid",
          message: "UUID can't be blank."
        }
      end
    end
  end
end