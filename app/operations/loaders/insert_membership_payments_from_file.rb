module Loaders
  class InsertMembershipPaymentsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      MembershipPaymentRecord.transaction do
        columns = [
        :id,
        :member_id,
        :membership_name,
        :membership_type,
        :amount,
        :date_paid,
        :status
        ]

        MembershipPaymentRecord.import columns, @data[:membership_payments]
      end
    end
  end
end
