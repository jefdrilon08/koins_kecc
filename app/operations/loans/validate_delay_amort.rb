module Loans
  class ValidateDelayAmort < AppValidator
    def initialize(config:)
      super()

      @config   = config
      @amort    = @config[:amort]
      @user     = @config[:user]
      @reason   = @config[:reason]
      @new_date = @config[:new_date].try(:to_date)

      @loan         = @amort.loan
      @member       = @loan.member
    end

    def execute!
      if @new_date.blank?
        @errors[:messages] << {
          key: "new_date",
          message: "New date required"
        }
      end

      if @new_date.present? and @new_date <= @amort.due_date
        @errors[:messages] << {
          key: "new_date",
          message: "Invalid date"
        }
      end

      if @reason.blank?
        @errors[:messages] << {
          key: "reason",
          message: "Reason required"
        }
      end

      if @loan.blank?
        @errors[:messages] << {
          key: "loan",
          message: "Loan not found"
        }
      elsif !@loan.active?
        @errors[:messages] << {
          key: "loan",
          message: "Loan is not active"
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
