module AdditionalShare
  class ValidateApprove
    def initialize(config:)
      super()
      @config = config
      @data_store = DataStore.find(@config[:data_store])
      @data       = @data_store.data.with_indifferent_access
      
      @errors     = {messages: []}
    end
    
    def by_hundred? number
      number % 100 == 0 ? true : false
    end
    def execute!
      @data[:record].each do |o|
        share = by_hundred? o[:total_add_capital]
        if share == false
          @errors[:messages] << {
            key: "member",
            message: "Additional Share Capital Amount Should be divisible by 100 - #{o[:name]}"
          }
        end
      end
      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      @errors
    end

  end
end
 
