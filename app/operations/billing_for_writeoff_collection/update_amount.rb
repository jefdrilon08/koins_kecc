module BillingForWriteoffCollection
  class UpdateAmount
    def initialize(config:)
      @config         = config
      @data_store_id  = @config[:data_store_id]
      @member_id      = @config[:member_id]
      @loan_id        = @config[:loan_id]
      @payment_amount         = @config[:payment_amount]
      @data_store     = DataStore.find(@data_store_id)
      @data           = @data_store.data.with_indifferent_access

    end

    def execute!
      member_data =  @data[:record].select{|x| x["member_id"] == @member_id}.last['loan_data']      
      loan_data = member_data.select{|z| z["loan_id"] == @loan_id}.last
      loan_data['amount'] = @payment_amount
      @data_store.update(data: @data)
    end

  end
end 
