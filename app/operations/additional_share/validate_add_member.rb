module AdditionalShare
  class ValidateAddMember
    def initialize(config:)
      super()
      @config     = config
      @member_id  = @config[:member_id]
      @data_store = DataStore.find(@config[:data_store_id])
      @data       = @data_store.data.with_indifferent_access
      @errors     = {messages: []}
    end
    
    def execute!
      if @member_id.blank?
        @errors[:messages] << {
          key: "member",
          message: "member not found"
        }
      end

      member = @data[:record].select{|x| x["member_id"] == @member_id}.last
      if member.present?
        @errors[:messages] << {
          key: "member",
          message: "member already exists"
        }
      end

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      @errors
    end


  end
end
 
