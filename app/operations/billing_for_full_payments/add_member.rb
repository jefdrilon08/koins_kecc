module BillingForFullPayments
  class AddMember
    def initialize(config:)
        config = config
        @data_store_details = DataStore.find(config[:data_store_id])
        @member_id  =    config[:member_id]
        @member_loan_id =   config[:member_loan_id]
        @member_details = Member.find(@member_id)
        
        
      
    end

    def execute!
      a_data =  @data_store_details.data
      a_meta =  @data_store_details.meta
      g = a_data.select{ |o| o["member_id"] == @member_id  }.first
    
      k = g["balance"].select{ |t| t["loan_product_id"] == @member_loan_id  }.last

      

      loan = Loan.where(loan_product_id: @member_loan_id, member_id: @member_id, status: "active")
      for_interest_paid = AmortizationScheduleEntry.where("loan_id = ? and due_date <= ? and is_paid is null", loan.last.id, @data_store_details.meta["collection_date"]).sum(:interest_balance)

    


      g["status"] = "active"
      k["enabled"] = true
      k["principal_balance"] = loan.last.principal_balance.to_f
      k["interest_balance"] = for_interest_paid.to_f
      k["amount"] = k["principal_balance"] + k["interest_balance"]
      


      meta_details = a_meta["header"][0].select{ |o| o["loan_product"] == @member_loan_id  }.first
      meta_details["receivable_amount"] =  (meta_details["receivable_amount"].to_f + k["principal_balance"].to_f)
      meta_details["interest_receivable_amount"] =  (meta_details["interest_receivable_amount"].to_f + k["interest_balance"].to_f)
  


      @data_store_details.save!

      

    end
  end
end
