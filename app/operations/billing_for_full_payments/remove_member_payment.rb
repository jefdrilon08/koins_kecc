module BillingForFullPayments
  class RemoveMemberPayment
    def initialize(config:)
    
      @data_store_id = config[:dataStoreId]
      @member_id = config[:memberId]
      @loan_product_id = config[:loanProductId]
      @loan_id = config[:loanId]
      @data_store = DataStore.find(@data_store_id)
      #@data_store = DataStore.find(@data_store_id)

    end
    def execute!
      data_store_member = @data_store.data.select{ |o| o["member_id"] == @member_id }
      data_store_meta = @data_store.meta["header"][0].select{ |h| h["loan_product"]  == @loan_id }
      member_loan = data_store_member.last["balance"].select{ |m| m["loan_id"] == @loan_product_id}.last  
      current_receivable_amount =  data_store_meta.last["receivable_amount"]
      current_interest_amount =  data_store_meta.last["interest_receivable_amount"]
      
      member_receivable_amount = member_loan["principal_balance"]
      member_interest_amount = member_loan["interest_balance"]
      
      deducted_principal = current_receivable_amount.to_f - member_receivable_amount.to_f
      deducted_interest = current_interest_amount.to_f - member_interest_amount.to_f

    
      data_store_meta.last["receivable_amount"]           = deducted_principal
      data_store_meta.last["interest_receivable_amount"]  = deducted_interest
  

      member_loan["principal_balance"] = 0.0
      member_loan["interest_balance"] = 0.0
      member_loan["amount"] = 0.0
      member_loan["enabled"] = false
      
      if data_store_member.last["balance"].sum{ |g| g["amount"]  } == 0
        data_store_member.last["status"] = "pending" 
      end
      

      @data_store.save!




    end
  end
end
