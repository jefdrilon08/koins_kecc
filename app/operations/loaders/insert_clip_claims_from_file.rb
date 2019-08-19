module Loaders
  class InsertClipClaimsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      ClipClaim.transaction do
        columns = [
          :id,
          :member_id,
          :center_id,
          :branch_id,
          :date_prepared,
          :creditors_name, 
          :policy_number,
          :date_of_birth,
          :member_name,
          :beneficiary,
          :gender, 
          :age, 
          :date_of_death,
          :cause_of_death,
          :effective_date_of_coverage, 
          :expiration_date_of_coverage, 
          :amount_of_loan, 
          :terms,
          :amount_payable_to_beneficiary,
          :prepared_by,
          :amount_payable_to_creditor, 
          :type_of_loan,
          :created_at, 
          :updated_at
        ]

        ClipClaim.import columns, @data[:clip_claims]
      end
    end
  end
end
