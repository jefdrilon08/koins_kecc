module MemberAccounts
  class SaveMemberAccountDailyStatement
    attr_accessor :member_account_daily_statement,
                  :member_account,
                  :transacted_at

    def initialize(member_account:, transacted_at:)
      @member_account = member_account
      @member         = @member_account.member
      @branch         = @member_account.branch
      @transacted_at  = transacted_at

      @member_account_daily_statement = MemberAccountDailyStatement.where(
                                          member_account_id: @member_account.id,
                                          member_id: @member_account.member_id,
                                          branch_id: @member_account.branch_id,
                                          transacted_at: @transacted_at
                                        ).first

      if @member_account_daily_statement.blank?
        @member_account_daily_statement = MemberAccountDailyStatement.new(
                                            member_account: @member_account,
                                            member: @member,
                                            branch: @branch,
                                            transacted_at: @transacted_at
                                          )
      end
    end

    def execute!
      transactions  = ReadOnlyAccountTransaction.where(
                        status: "approved",
                        subsidiary_id: @member_account.id
                      ).where(
                        "DATE(transacted_at) = ?", @transacted_at
                      )

      debit_amount  = transactions.where(
                        transaction_type: ["withdraw"]
                      ).sum(:amount).round(2)

      credit_amount = transactions.where(
                        transaction_type: ["deposit"]
                      ).sum(:amount).round(2)

      @member_account_daily_statement.debit_amount  = debit_amount
      @member_account_daily_statement.credit_amount = credit_amount

      @member_account_daily_statement.save!

      @member_account_daily_statement
    end
  end
end
