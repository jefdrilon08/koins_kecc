module Accounting
  class FormatGeneralLedger
    def initialize(general_ledger_data:)
      @general_ledger_data  = general_ledger_data
    end

    def execute!
      @general_ledger_data
    end
  end
end
