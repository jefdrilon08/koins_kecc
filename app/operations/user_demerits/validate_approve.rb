module UserDemerits
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @user_demerit = config[:user_demerit]
      @user = config[:user]
    end

    def execute!
      if @user_demerit.blank?
        @errors[:messages] << {
          key: "user_demerit",
          message: "Demerit not found"
        }
      elsif !@user_demerit.pending?
        @errors[:messages] << {
          key: "user_demerit",
          message: "Demerit not pending"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User not found"
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
