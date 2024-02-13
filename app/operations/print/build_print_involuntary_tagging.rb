module Print
  class BuildPrintInvoluntaryTagging
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config = config
      @print_involuntary = DataStore.find(@config)
      @print_involuntary_data = @print_involuntary.data.with_indifferent_access
      @data_records = @print_involuntary_data[:records]
      @data = {}
      @array = []
      @savingsdebitarray = []
      @savingscreditarray = []

    end

    def execute!

      @data[:company_name]          = Settings.company_name
      @data[:company_address]       = Settings.company_address
      @data[:particular]             = @print_involuntary_data["accounting_entry_transfer_savings"]["particular"]
      @data[:approved_by]            = @print_involuntary_data["accounting_entry_transfer_savings"]["approved_by"]
      @data[:prepared_by]            = @print_involuntary_data["accounting_entry_transfer_savings"]["prepared_by"]

      #loop for member
      @print_involuntary_data["records"].each do |rec|
        @data_records     = {}
        @data_records[:member_name]   = rec["member_name"]
        @data_records[:loan_records]  = rec["loan_records"]
        @array << @data_records

      #     loop for accounting Entry savings
      @print_involuntary_data["accounting_entry_transfer_savings"]["debit_journal_entries"].each do |savingdebit|
        @debit_journal_entries = {}
        @debit_journal_entries[:name]    = savingdebit["name"]
        @debit_journal_entries[:amount]  = savingdebit["amount"]
        @debit_journal_entries[:code]    = savingdebit["code"]
        @data[:debit_journal_entries] = @debit_journal_entries
        #raise @print_involuntary_data["accounting_entry_transfer_savings"]["debit_journal_entries"].inspect
        #raise  @data[:debit_journal_entries].inspect
        @savingsdebitarray << @debit_journal_entries
      end

      @print_involuntary_data["accounting_entry_transfer_savings"]["credit_journal_entries"].each do |savingcredit|

        @credit_journal_entries = {}
        @credit_journal_entries[:name]    = savingcredit["name"]
        @credit_journal_entries[:amount]  = savingcredit["amount"]
        @credit_journal_entries[:code]    = savingcredit["code"]
        @data[:credit_journal_entries] = @credit_journal_entries
        @savingscreditarray << @credit_journal_entries
      end

      @data[:debit_journal_entries] = @savingsdebitarray
      @data[:credit_journal_entries] = @savingscreditarray
    end
    end
  end
end
