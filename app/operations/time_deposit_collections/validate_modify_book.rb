module TimeDepositCollections
  class ValidateModifyBook < AppValidator
    def initialize(config:)
      super()
      @config = config

      @book                     = @config[:book]
      @time_deposit_collection  = @config[:time_deposit_collection]
    end

    def execute!
      if @time_deposit_collection.blank?
        @errors << {
          name: "time_deposit_collection",
          message: "Time Deposit collection not found"
        }
      elsif !@time_deposit_collection.pending?
        @errors << {
          name: "time_deposit_collection",
          message: "Time Deposit collection is not pending"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
