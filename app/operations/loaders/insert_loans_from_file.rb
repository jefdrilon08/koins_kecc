module Loaders
  class InsertLoansFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Loan.transaction do
        columns = [
          :id,
          :center_id,
          :branch_id,
          :date_prepared,
          :date_approved,
          :date_released,
          :date_completed,
          :member_id,
          :principal,
          :interest,
          :principal_paid,
          :principal_balance,
          :interest_paid,
          :interest_balance,
          :status,
          :loan_product_id,
          :term,
          :pn_number,
          :payment_type,
          :num_installments,
          :monthly_interest_rate,
          :project_type_id,
          :data
        ]

        Loan.import columns, @data[:loans]
      end
    end
  end
end
