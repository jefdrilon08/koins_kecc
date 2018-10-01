module Loaders
  class InsertMemberAccountsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      MemberAccount.transaction do
        columns = [
          :id,
          :member_id,
          :account_type,
          :account_subtype,
          :balance,
          :center_id,
          :branch_id,
          :status,
          :maintaining_balance
        ]

        MemberAccount.import columns, @data[:member_accounts], validate: false
      end
    end
  end
end
