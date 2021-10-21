module BillingForFullPayments
  class UpdateBillingAmount

    def initialize(config:)
    
      @config             = config
      @member_id          = @config[:member_id]
      @member_account_id  = @config[:member_account_id]
      @data_store_id      = @config[:data_store_id]
      @record_type        = @config[:record_type]
      @loan_amount        = @config[:loan_amount]
    end

    def execute!
         
        data_store = DataStore.find(@data_store_id)
        data_store_details = data_store["data"].select{ |b| b["member_id"] ==  @member_id }.first["balance"]
        wp_amount = data_store_details.select{ |r| r["record_type"] == "WP"  }

        
        wp_amount.first["amount"] = @loan_amount.to_f
        wp_header =  data_store.meta["header"][0].select{ |h| h["loan_product"] == "WP"  }
      
        get_balance_details = data_store.data.sum{ |b| b["balance"] }
        get_balance_wp = get_balance_details.select{ |b| b["record_type"] == "WP" }

        
        #get_balance_wp.sum{ |a| a["amount"] }

        data_store.meta["header"][0].select{ |w| w["loan_product"] == "WP"}.first["amount"] = get_balance_wp.sum{ |a| a["amount"] }
        

        


        data_store.save!
    
      
        
    end

  end
end
