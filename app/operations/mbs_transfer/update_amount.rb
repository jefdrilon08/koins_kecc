module MbsTransfer
  class UpdateAmount
  
    def initialize(config:)
      @config             = config
      @data_store_id      = @config[:data_store_id]
      @member_id          = @config[:member_id]
      @member_account_id  = @config[:member_account_id]
      @withdraw_amount    = @config[:withdraw_amount]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @member           = @data[:record].select{|x| x["member_id"] == @member_id}.last
      @member_data      = @member['records']
    end
   
    def execute!
      update_withdraw!
      update_add_share_cap!
      @data_store.update(data: @data) 
    end

    def update_withdraw!
      withdraw_data = @member_data.select{|wd| wd["member_account_id"] == @member_account_id}.last
      withdraw_data[:amount] = @withdraw_amount.to_f
    end

    def update_add_share_cap!
      total_amount = @member_data.sum { |sc| sc['amount'].to_f}
      @member['total_add_capital'] = total_amount.to_f
    end

  end
end
