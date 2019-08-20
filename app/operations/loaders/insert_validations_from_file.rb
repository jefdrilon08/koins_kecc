
module Loaders
  class InsertValidationsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      MemberAccountValidation.transaction do
        columns = [
          :id,
          :branch_id,
          :date_prepared,
          :status,
          :prepared_by,
          :approved_by,
          :particular,
          :reference_number,
          :total,
          :or_number,
          :date_approved,
          :date_validated,
          :validated_by,
          :date_checked,
          :checked_by,
          :date_cancelled,
          :cancelled_by,
          :is_remote ,
          :total_rf,
          :total_50_percent_lif,
          :total_advance_lif,
          :total_advance_rf,
          :total_interest,
          :total_equity_interest,
          :created_at,
          :updated_at
        ]

        MemberAccountValidation.import columns, @data[:validations]
      end
    end
  end
end

