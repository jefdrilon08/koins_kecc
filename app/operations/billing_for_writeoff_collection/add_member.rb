module BillingForWriteoffCollection
  class AddMember
    def initialize(config:)
      @config         = config
      @data_store_id  = @config[:data_store_id]
      @member_id      = @config[:member_id]
      @data_store     = DataStore.find(@data_store_id)
      @data           = @data_store.data.with_indifferent_access

    end
    
    def add_member!
      member_update = @data[:record].select{|x| x["member_id"] == @member_id}.last
      member_update['enabled'] = true
    end

    def add_amort!
      member = @data[:record].select{|x| x["member_id"] == @member_id}.last
      member_loan = member['loan_data'].select{|y| y[:enabled] == true && y[:name] != "Withdraw Payment"}
      member_loan.each do |mem_loan|
        amort = AmortizationScheduleEntry.where(loan_id: mem_loan[:loan_id]).unpaid
	amort.each do |amorts|
	  mem_loan[:loan_amort] << {
	    amort_id: amorts.id,
	    principal_balance: amorts.principal_balance.to_f,
	    interest_balance: amorts.interest_balance.to_f,
            total_balance:  amorts.principal_balance.to_f + amorts.interest_balance.to_f,
            principal_amount: amorts.principal_balance.to_f,
            interest_amount: amorts.interest_balance.to_f,
	    due_date: amorts.due_date.to_date
	  }		
	end
      end
    end

    def execute!
      add_member!
      add_amort!
      @data_store.update(data: @data)
    end

  end
end 
