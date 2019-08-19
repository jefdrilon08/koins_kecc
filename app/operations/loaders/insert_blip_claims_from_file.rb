module Loaders
  class InsertBlipClaimsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Claim.transaction do
        columns = [
          :id,
          :date_prepared,
          :policy_number,
          :type_of_insurance_policy,
          :name_of_insured,
          :beneficiary,
          :classification_of_insured,
          :date_of_birth,
          :gender,
          :date_of_policy_issue,
          :face_amount,
          :date_of_death_tpd_accident,
          :arrears,
          :cause_of_death_tpd_accident,
          :amount_benefit_payable,
          :equity_value,
          :retirement_fund,
          :prepared_by,
          :length_of_stay,
          :returned_contribution,
          :total_amount_payable,
          :order_of_child,
          :category_of_cause_of_death_tpd_accident,
          :date_reported,
          :date_paid,
          :created_at,
          :updated_at,
          :member_id,
          :center_id,
          :branch_id 
        ]

        Claim.import columns, @data[:claims]
      end
    end
  end
end

