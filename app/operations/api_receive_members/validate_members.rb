module ApiReceiveMembers
  class ValidateMembers < AppValidator
    def initialize(config:)
      super()

      @config             = config
      @api_receive_member = @config[:api_receive_member]
      @data               = @api_receive_member[:data]
    end

    def execute!
      # raise @data.inspect
      @data.each do |o|
        if o["middle_name"].nil?
          @errors[:messages] << {
            key: "middle_name",
            message: "Middle Name is Empty"
          }
        end
      end

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
