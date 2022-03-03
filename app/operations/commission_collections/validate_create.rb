module CommissionCollections
  class ValidateCreate < AppValidator
    def initialize(config:)
      super()
      @config = config

      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @category   = @config[:category]
      @user       = @config[:user]
    end

    def execute!
      #not_yet_implemented!

      if @start_date.blank?
        @errors[:messages] << {
          key: "start_date",
          message: "Start date required"
        }
      end

      if @end_date.blank?
        @errors[:messages] << {
          key: "end_date",
          message: "End date required"
        }
      end

      if @category.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Category required"
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
