module BillingForInvoluntary
  class UpdateAmount
    def initialize(config:)
      @config           = config
      @data_store_id    = @config[:data_store_id]
      @member_id        = @config[:member_id]
      @loan_id          = @config[:loan_id]
      @payment_amount   = @config[:payment_amount]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @member           = @data[:record].select{|x| x["member_id"] == @member_id}.last
      @member_data      = @member['loan_data']
    end
  end 
end