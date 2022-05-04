module BillingForWriteoffCollection
  class AddMember
    def initialize(config:)
      @config         = config
      @data_store_id  = @config[:data_store_id]
      @member_id      = @config[:member_id]
      @data_store     = DataStore.find(@data_store_id)
      @data           = @data_store.data.with_indifferent_access

    end

    def execute!
      member_update = @data[:record].select{|x| x["member_id"] == @member_id}.last
      member_update['enabled'] = true
      @data_store.update(data: @data)
    end

  end
end 
