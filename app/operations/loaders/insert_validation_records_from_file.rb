
module Loaders
  class InsertValidationRecordsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      MemberAccountValidationRecord.transaction do
        columns = [
          :id,
          :member_account_validation_id,
          :member_id, 
          :center_id,
          :status,
          :transaction_number,
          :rf,
          :lif_50_percent,
          :advance_rf,
          :interest,
          :equity_interest,
          :total,
          :resignation_date,
          :member_classification,
          :created_at,
          :updated_at,
          :advance_lif

        ]

        MemberAccountValidationRecord.import columns, @data[:validation_records]
      end
    end
  end
end

