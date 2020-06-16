module EquityWithdrawalCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config                           = config
      @equity_withdrawal_collection     = @config[:equity_withdrawal_collection]
      @user                             = @config[:user]

      @data = @equity_withdrawal_collection.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @equity_withdrawal_collection.blank?
        @errors[:messages] << {
          key: "equity_withdrawal_collection",
          message: "equity_withdrawal_collection not found"
        }
      end

      if @data.present? and @data[:records].size == 0
        @errors[:messages] << {
          key: "records",
          message: "no records found"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
