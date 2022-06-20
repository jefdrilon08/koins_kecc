module AdditionalShare
  class UpdateTotal
    def initialize(config:)
      @config           = config
      @data_store_id    = @config[:data_store_id]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @record           = @data[:record]
      @header           = @data[:header]
    end
    

    def update_total_withdraw!
      @header.each do |header|
        if header[:name] != "ADDITIONAL SHARE CAP"
          @total_amount = []
          @record.each do |record|
            total_amount = record['records'].select{|r| r['accounting_code_id'] == header[:accounting_code_id]}.last[:amount]

            @total_amount << total_amount.to_f
          end
          header[:total_amount] = @total_amount.sum.to_f
        end
      end

    end

    def update_total_share_cap!
      header = @header.select{|hd| hd['name'] == "ADDITIONAL SHARE CAP"}.last
      @total_add_capital = []
      @record.each do |record|
        @total_add_capital << record['total_add_capital'].to_f
      end
      header[:total_amount] = @total_add_capital.sum.to_f
    end

    def execute!
      update_total_withdraw!
      update_total_share_cap!
      @data_store.update(data: @data)
    end


  end
end

