module Members
  class ValidateLastAccountTransactionDate
    def initialize(member:, reinstatement_date:, date_stop:)
      @member                       = member
      @reinstatement_date           = reinstatement_date.to_date
      @date_stop                    = date_stop.to_date
      @member_id                    = @member.id
      @member_accounts_lif          = MemberAccount.where(member_id: @member_id, account_subtype: "Life Insurance Fund").ids
      @last_account_transaction     = AccountTransaction.where(subsidiary_id: @member_accounts_lif).order(created_at: :desc).first
      @last_transaction_date        = @last_account_transaction["transacted_at"].to_date
    end

    def execute!

      if @reinstatement_date.nil?
        raise "Reinstatement Date is blank, Please fill up."
      end

      if @date_stop.nil?
        raise "Date Stop is blank, Please fill up."
      end

      if @last_transaction_date != @reinstatement_date
        raise "Failed to Reinstatement this Member. #{@last_transaction_date}"
      end

      @last_transaction_date
    end
  end
end
