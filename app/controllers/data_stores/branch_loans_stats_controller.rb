module DataStores
  class BranchLoansStatsController < DataStoreController
    private

    def data_store_scope
      "repayment_rates" # There's no .branch_loan_stats scope
    end
  end
end
