module Loaders
  class InsertMemberSharesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      MemberAccount.transaction do
        columns = [
          :id,
          :member_id,
          :certificate_number,
          :date_of_issue,
          :data
        ]

        MemberShare.import columns, @data[:member_shares], validate: false
      end
    end
  end
end
