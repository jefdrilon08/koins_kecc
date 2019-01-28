module DepositCollections
  class ValidateModifyCashManagementTemplate < AppValidator
    def initialize(config:)
      super()
      @config = config

      @template           = @config[:template]
      @deposit_collection = @config[:deposit_collection]
    end

    def execute!
      if @deposit_collection.blank?
        @errors << {
          name: "deposit_collection",
          message: "Deposit collection not found"
        }
      elsif !@deposit_collection.pending?
        @errors << {
          name: "deposit_collection",
          message: "Deposit collection is not pending"
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
