module Print
  class BuildIcprAccountingEntry
  	include ActionView::Helpers::NumberHelper
  	def initialize(data_entry:)
      @data_entry = data_entry
      @data       = {}
    end

    def execute!
    	data_accounting_entry         = @data_entry.data.with_indifferent_access[:accounting_entry]
    	@data[:date_prepared]         = data_accounting_entry[:date_prepared]
    	@data[:book]                  = data_accounting_entry[:book]
	    @data[:reference_number]      = data_accounting_entry[:reference_number]
	    @data[:data]                  = data_accounting_entry[:data]
	    @data[:prepared_by]           = data_accounting_entry[:prepared_by]
	    @data[:approved_by]           = data_accounting_entry[:approved_by]
	    @data[:company_name]          = Settings.company_name
	    @data[:company_address]       = Settings.company_address
	    @data[:branch]                = data_accounting_entry[:branch]
	    @data[:particular]            = data_accounting_entry[:particular]
	    @data[:payee]                 = data_accounting_entry[:data][:payee]
	    @data[:sub_reference_number]  = data_accounting_entry[:data][:sub_reference_number]
	    @data[:or_number]  			  = data_accounting_entry[:data][:or_number]
	    @data[:check_number]          = data_accounting_entry[:data][:check_number]
	    @data[:ar_number]             = data_accounting_entry[:data][:ar_number]
		@data[:total_debit]			  = 0.00
		@data_total_credit		      = []
	    if data_accounting_entry[:date_posted].present?
        @data[:date_posted] = data_accounting_entry[:date_posted]
      	end

      	@data[:debit_journal_entries] = []
      	
      	data_accounting_entry[:debit_journal_entries].each do |o|
        @data[:debit_journal_entries] << {
          code: o[:code],
          name: o[:name],
          amount: number_to_currency(o[:amount], unit: "")
        }
        @data[:total_debit]   = number_to_currency(o[:amount], unit: "")
      	end
      	
      	@data[:credit_journal_entries] = []

      	data_accounting_entry[:credit_journal_entries].each do |o|
        @data[:credit_journal_entries] << {
          code: o[:code],
          name: o[:name],
          amount: number_to_currency(o[:amount], unit: "")
        }
      	@data_total_credit	<< o[:amount]
      	end
	    
	   	@data[:total_credit]= number_to_currency(@data_total_credit.sum, unit: "")
      @data

    end

  end
end