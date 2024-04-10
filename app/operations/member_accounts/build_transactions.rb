module MemberAccounts
  class BuildTransactions
    attr_accessor :data

    def initialize(member:, member_account:, last_id:, limit: 20)
      @member         = member
      @member_account = member_account
      @last_id        = last_id
      @limit          = limit

      @data = {
        last_id: "",
        transactions: []
      }
    end

    def execute!
      if @last_id.present?
        @last_transaction = AccountTransaction.find_by_id_and_subsidiary_id(
          @last_id,
          @member_account.id
        )
      end

      if @last_transaction.blank?
        @last_transaction = AccountTransaction.where(
          subsidiary_id: @member_account.id
        ).order("transacted_at DESC, created_at DESC").first
      end

      if @last_transaction.present?
        @data[:transactions] = AccountTransaction.where(
          subsidiary_id: @member_account.id
        ).where.not(
          id: @last_transaction.id
        ).where(
          "DATE(transacted_at) <= ?",
          @last_transaction.transacted_at.to_date
        ).order(
          "transacted_at DESC, created_at DESC"
        ).limit(@limit).map{ |o|
          {
            id: o.id,
            amount: o.amount.to_f,
            transaction_type: o.transaction_type,
            transacted_at: o.transacted_at.strftime("%b %d, %Y"),
            is_interest: o.interest? ? "yes" : "no"
          }
        }

        if @data[:transactions].last[:id] != @last_id
          @data[:last_id] = @data[:transactions].last[:id]
        end
      end

      @data
    end
  end
end
