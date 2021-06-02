module Loans
  class ValidateReject < AppValidator
    attr_accessor :user,
                  :loan,
                  :reason,
                  :errors

    def initialize(user: nil, loan: nil, reason: nil)
      super()

      @user   = user
      @loan   = loan
      @reason = reason

      @valid_roles  = ::Users::FetchValidRoles.new(
                        module_name: "online_loan_application_verification"
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

      if @reason.blank?
        @errors[:messages] << {
          key: "reason",
          message: "reason required"
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
