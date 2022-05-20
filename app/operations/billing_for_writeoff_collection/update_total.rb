module BillingForWriteoffCollection
  class UpdateTotal
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
    
    def update_total_amount!
      record = @data[:record]
      header = @data[:header]
      header.each do |hd|
        enabled_loan = record.select{|y| y[:enabled] == true}
        @total_amount = []
        enabled_loan.each do |el|
          total_amount = el['loan_data'].select{|u| u['name'] == hd[:name] &&u['enabled'] = true}.last[:amount]
          @total_amount << total_amount
        end
          hd[:total_amount] = @total_amount.sum
      end
    end

    def execute!
      update_total_amount!
      @data_store.update(data: @data)
    end
  
  end
end
 
