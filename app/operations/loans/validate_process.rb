module Loans
  class ValidateProcess < AppValidator
    attr_accessor :user,
                  :loan,
                  :errors

    def initialize(user:, loan:)
      super()

      @user = user
      @loan = loan

      @valid_roles  = ::Users::FetchValidRoles.new(
                        module_name: "online_loan_application_process"
                      ).execute!
    end

    def execute!
      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user required"
        }
      elsif @user.current_roles.intersection(@valid_roles).size == 0
        @errors[:messages] << {
          key: "user",
          message: "unauthorized"
        }
      end

      if @loan.blank?
        @errors[:messages] << {
          key: "loan",
          message: "loan required"
        }
      elsif !@loan.for_verification?
        @errors[:messages] << {
          key: "loan",
          message: "invalid loan status"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
