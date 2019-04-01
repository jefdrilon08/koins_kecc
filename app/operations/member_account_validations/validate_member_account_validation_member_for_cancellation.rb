module MemberAccountValidations
  class ValidateMemberAccountValidationMemberForCancellation < AppValidator

    def initialize(config:)
      super()

      @config         = config
      @member         = @config[:member]
      @date_cancelled = @config[:date_cancelled]
      @reason         = @config[:reason]
    end

    def execute!
      if @reason.nil?
        @errors[:messages] << {
          key: "member",
          message: "Reason cant be blank."
        }
      end

      if @date_cancelled.nil?
        @errors[:messages] << {
          key: "member",
          message: "Date cancelled cant be blank."
        } 
      end

      if @member.nil?
        @errors[:messages] << {
          key: "member",
          message: "Member cant be blank."
        }
      end 

      @errors     
    end
  end
end
