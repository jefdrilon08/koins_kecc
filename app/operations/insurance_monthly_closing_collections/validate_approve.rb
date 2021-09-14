module InsuranceMonthlyClosingCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()
      @config = config

      @insurance_monthly_closing_collection = @config[:insurance_monthly_closing_collection]
      @user                                 = @config[:user]
    end

    def execute!
      #not_yet_implemented!

      if @insurance_monthly_closing_collection.blank?
        @errors[:messages] << {
          key: "insurance_monthly_closing_collection",
          message: "Record not found"
        }
      elsif !@insurance_monthly_closing_collection.pending?
        @errors[:messages] << {
          key: "insurance_monthly_closing_collection",
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
