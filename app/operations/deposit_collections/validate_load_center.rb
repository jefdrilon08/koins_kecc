module DepositCollections
  class ValidateLoadCenter < AppValidator
    def initialize(config:)
      super()

      @config             = config
      @deposit_collection = @config[:deposit_collection]
      @center             = @config[:center]
      @user               = @config[:user]
    end

    def execute!
      if @deposit_collection.blank?
        @errors[:messages] << {
          key: "deposit_collection",
          message: "Record not found"
        }
      elsif @deposit_collection.not_pending?
        @errors[:messages] << {
          key: "deposit_collection",
          message: "Record not pending"
        }
      end

      if @center.blank?
        @errors[:messages] << {
          key: "center",
          message: "Center not found"
        }
      end

      if @deposit_collection.finalized?
        @errors[:messages] << {
          key: "deposit_collection",
          message: "Deposit Collection already finalized!"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
