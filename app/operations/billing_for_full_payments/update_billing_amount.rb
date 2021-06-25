module BillingForFullPayments
  class UpdateBillingAmount

    def initialize(config:)
      @config = config
      @loan_id         = @config[:loan_id]
      @loan_product_id = @config[:loan_product_id]
      @data_store_id   = @config[:data_store_id]
      @loan_amount     = @config[:loan_amount]
    
    end

    def execute!
      data_store = DataStore.find(@data_store_id)
      data_store_details = data_store["data"].select{ |b| b["loan_id"] ==  @loan_id }.first["balance"].select{ |bb| bb["loan_product_id"] == @loan_product_id }.first
      data_store_details["amount"] = @loan_amount
      data_store.save!
    end

  end
end
