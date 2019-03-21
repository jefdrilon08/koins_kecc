module Members
  class ValidateChangeRecognitionDate < AppValidator
    def initialize(config:)
      super()

      @config           = config
      @member           = @config[:member]
      @user             = @config[:user]
      @recognition_date = @config[:recognition_date].try(:to_date)
    end

    def execute!  
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "member not found"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      end

      if @recognition_date.blank?
        @errors[:messages] << {
          key: "recognition_date",
          message: "No member type found"
        }
      end

      if @member.present? and @recognition_date.present? and @member.recognition_date == @recognition_date
        @errors[:messages] << {
          key: "recognition_date",
          message: "Same recognition date"
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
