module CommissionCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()
      @config = config

      @commission_collection = @config[:commission_collection]
      @user                  = @config[:user]
    end

    def execute!
      #not_yet_implemented!

      if @commission_collection.blank?
        @errors[:messages] << {
          key: "commission_collection",
          message: "Record not found"
        }
      elsif !@commission_collection.pending?
        @errors[:messages] << {
          key: "commission_collection",
          message: "Record not pending"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User required"
        }
      end
      
      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
