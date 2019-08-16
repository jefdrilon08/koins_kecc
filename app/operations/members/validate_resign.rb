module Members
  class ValidateResign
    def initialize(member:, date_resigned:)
      @member             = member
      @date_resigned      = date_resigned
      @insurance_types    = MemberAccount.insurance.where(id: Settings.member_resignation_types)
      @insurance_accounts = AccountTransaction.where(subsidiary_id: @insurance_types.pluck(:id))
      @errors             = []
    end

    def execute!
      @insurance_accounts.each do |insurance_account|
        if insurance_account.data['balance'] != 0
          @errors << "Insurance Account #{insurance_account.id} still has balance. Please withdraw first"
        end
      end

      if !@insurance_types
        @errors << "No insurance types found"
      end

      if !@member.present?
        @errors << "Member not found"
      end

      if !@date_resigned.present?
        @errors << "Date resigned required"
      end

      @errors
    end
  end
end

