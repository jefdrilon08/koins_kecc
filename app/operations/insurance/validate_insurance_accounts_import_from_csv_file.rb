module Insurance
  class ValidateInsuranceAccountsImportFromCsvFile < AppValidator
    def initialize(config:)
      super()

      @insurance_account = config[:insurance_account]
    end

    def execute!
      check_if_account_type_present!
      check_if_account_subtype_present!
      check_if_status_present!
      check_if_member_id_present!
      check_if_uuid_present!
      @errors
    end

    private

    def check_if_account_type_present!
      if @insurance_account['account_type'].nil?
        @errors[:messages] << {
          key: "account_type",
          message: "Account Type Type can't be blank."
        }
      end      
    end

    def check_if_account_subtype_present!
      if @insurance_account['account_subtype'].nil?
        @errors[:messages] << {
          key: "account_subtype",
          message: "Account Subtype Type can't be blank."
        }
      end      
    end

    def check_if_member_id_present!
      if @insurance_account['member_id'].nil?
        @errors[:messages] << {
          key: "member_id",
          message: "Member ID can't be blank."
        }
      end
    end

    def check_if_status_present!
      if @insurance_account['status'].nil?
        @errors[:messages] << {
          key: "status",
          message: "Status can't be blank."
        }
      end
    end

    def check_if_uuid_present!
      if @insurance_account['uuid'].nil?
         @errors[:messages] << {
          key: "uuid",
          message: "UUID can't be blank."
        }
      end
    end
  end
end
