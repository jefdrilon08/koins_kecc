module EquityAccounts
  class ValidateUpdateEquityValue < AppValidator
    def initialize(config:)
      super()

      @equity_account = config[:equity_account]
      @equity_value = config[:equity_value].try(:to_f)
      @user = config[:user]
      @valid_roles = Settings.try(:module_authorization_roles).try(:unlock_member_modification) || []
      @current_roles = @user&.current_roles || []
    end

    def execute!
      if @user.blank?
        @errors[:messages] << { key: "user", message: "User not found" }
      elsif (@valid_roles & @current_roles).empty?
        @errors[:messages] << { key: "user", message: "Invalid role. Valid roles are: #{@valid_roles}" }
      end

      if @equity_value.present? && @equity_value < 0
        @errors[:messages] << { key: "equity_value", message: "Invalid amount" }
      end

      if @equity_account.blank?
        @errors[:messages] << { key: "equity_account", message: "CBU equity account not found" }
      end

      @errors[:messages].each { |error| @errors[:full_messages] << error[:message] }
      @errors
    end
  end
end
