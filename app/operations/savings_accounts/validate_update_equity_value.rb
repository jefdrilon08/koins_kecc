module SavingsAccounts
  class ValidateUpdateEquityValue < AppValidator
    def initialize(config:)
      super()

      @config = config
      @savings_account = @config[:savings_account]
      @equity_value = @config[:equity_value].try(:to_f)
      @user = @config[:user]

      @valid_roles = Settings.try(:module_authorization_roles).try(:unlock_member_modification) || []
      @current_roles = @user&.current_roles || []
    end

    def execute!
      if @user.present?
        if (@valid_roles & @current_roles).size == 0
          @errors[:messages] << {
            key: 'user',
            message: "Invalid role. Valid roles are: #{@valid_roles}"
          }
        end
      else
        @errors[:messages] << {
          key: 'user',
          message: 'User not found'
        }
      end

      if @equity_value.present? && @equity_value < 0
        @errors[:messages] << {
          key: 'equity_value',
          message: 'Invalid amount'
        }
      end

      if @savings_account.blank?
        @errors[:messages] << {
          key: 'savings_account',
          message: 'Account not found'
        }
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
