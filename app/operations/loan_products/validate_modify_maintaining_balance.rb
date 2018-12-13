module LoanProducts
  class ValidateModifyMaintainingBalance < AppValidator
    def initialize(config:)
      super()
      @config = config

      @maintaining_balance  = @config[:maintaining_balance].try(:to_f)
    end

    def execute!
      if @maintaining_balance.blank?
        @errors << {
          key: "maintaining_balance",
          message: "maintaining_balance value required"
        }
      elsif @maintaining_balance < 0.00
        @errors << {
          key: "maintaining_balance",
          message: "maintaining_balance cannot be less than 0.00"
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
