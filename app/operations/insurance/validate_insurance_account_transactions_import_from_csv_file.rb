module Insurance
  class ValidateInsuranceAccountTransactionsImportFromCsvFile < AppValidator
    def initialize(config:)
      super()

      @insurance_account_transaction = config[:insurance_account_transaction]
    end

    def execute!
      check_if_insurance_account_uuid_present!

      @errors
    end

    private

    def check_if_insurance_account_uuid_present!
      if @insurance_account_transaction['subsidiary_id'].nil?
        @errors[:messages] << {
          key: "subsidiary_id",
          message: "Subsidiary ID can't be blank."
        }
      end
    end 

    def check_if_uuid_present!
      if @insurance_account_transaction['id'].nil?
        @errors[:messages] << {
          key: "id",
          message: "ID can't be blank."
        }
      end
    end
  end
end