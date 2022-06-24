module Print
  class SubsidiaryPrint
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config =config
      @adjustment_record = AdjustmentRecord.find(@config)
      @adjustment_record_data = @adjustment_record.data.with_indifferent_access
      @data             = {}
      @array = []
      @debitarray = []
      @creditarray = []

    end
    def execute!
     
      
        @data[:company_name]          = Settings.company_name
        @data[:company_address]       = Settings.company_address
        @data[:branch]                = @adjustment_record.meta["branch"]["name"].to_s.upcase
        @data[:particular]            = @adjustment_record_data["accounting_entry"]["particular"]
        @data[:approved_by]          = @adjustment_record_data["accounting_entry"]["approved_by"]
        @data[:prepared_by]           = @adjustment_record_data["accounting_entry"]["prepared_by"]
        #@data[:name]                 = @adjustment_record_data["accounting_entry"]["debit_journal_entries"][0]["name"]
        #@data[:amount]             = @adjustment_record_data["accounting_entry"]["debit_journal_entries"][0]["amount"]
          
        #loop for records -> member 
        @adjustment_record_data["records"].each do |rec|
          @data_records     = {}
          @data_records[:last_name]     = rec["member"]["last_name"]
          @data_records[:first_name]    = rec["member"]["first_name"]
          @data_records[:middle_name]   = rec["member"]["middle_name"]
          @data_records[:center_name]   = rec["center"]["name"]
          @data_records[:adjustment_type] = rec["adjustment"]
          @data_records[:account_subtype] = rec[:member_account][:account_subtype]
          @data_records[:amount]          =  rec[:amount]
      

          @array <<  @data_records
        end
        

        @adjustment_record_data["accounting_entry"]["debit_journal_entries"].each do |debit|
         
          @debit_journal_entries     = {}
          @debit_journal_entries[:name]         = debit["name"]
          @debit_journal_entries[:amount]       = debit["amount"]
          @debit_journal_entries[:code]         = debit["code"]
          @data[:debit_journal_entries] = @debit_journal_entries
          #raise @debit_journal_entries.inspect
          @debitarray << @debit_journal_entries
        end
         

        @adjustment_record_data["accounting_entry"]["credit_journal_entries"].each do |credit|
          
          @credit_journal_entries                = {}          
          @credit_journal_entries[:name]         = credit["name"]
          @credit_journal_entries[:amount]       = credit["amount"]
          @credit_journal_entries[:code]         = credit["code"]
         @data[:credit_journal_entries] = @credit_journal_entries
         @creditarray << @credit_journal_entries
        end

      @data[:records] = @array
      @data[:debit_journal_entries] = @debitarray
      @data[:credit_journal_entries] = @creditarray
      

      @data
    end
  end
end