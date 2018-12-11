module Loans
  class ValidateDelete < AppValidator
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]

      @valid_roles  = ["MIS", "BK", "SBK"]
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
      elsif (@valid_roles & @user.roles).size == 0
        @errors[:messages] << {
          key: "user",
          message: "unauthorized roles: #{@user.roles}"
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
