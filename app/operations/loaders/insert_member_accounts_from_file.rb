module Loaders
  class InsertMemberAccountsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)

      # avoid duplicates
      @unique_member_accounts = []

      @columns = [
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


      @data[:member_accounts].each do |o|
        if MemberAccount.where(id: o[:id]).size == 0
          @unique_member_accounts << o
        end
      end
    end

    def execute!
      MemberAccount.transaction do
        MemberAccount.import @columns, @unique_member_accounts, validate: false
      end
    end
  end
end
