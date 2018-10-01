module Loaders
  class InsertAmortizationScheduleEntriesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      AmortizationScheduleEntry.transaction do
        columns = [
          :id, 
          :amount_due,
          :principal,
          :interest,
          :principal_paid,
          :interest_paid,
          :principal_balance,
          :interest_balance,
          :due_date,
          :is_paid,
          :loan_id,
          :data
        ]

        AmortizationScheduleEntry.import columns, @data[:amortization_schedule_entries], validate: false
      end
    end
  end
end
