module Loans
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]
    end

    def execute!
      if @loan.blank?
        @errors[:messages] << {
          key: "loan",
          message: "Loan not found"
        }
      elsif !@loan.pending?
        @errors[:messages] << {
          key: "loan",
          message: "Loan not pending"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User not found"
        }
      end

      not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
