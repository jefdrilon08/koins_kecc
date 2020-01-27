module Icpr
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config = config

      @data_store = @config[:data_store]
      @user       = @config[:user]
    end

    def execute!
      if !@data_store.done?
        @errors[:messages] << {
          key: "status",
          message: "Cannot approve record"
        }
      end

      if @data_store.data["total_equity_interest_amount"].to_f.round(2) == 0.00
        @errors[:messages] << {
          key: "total_equity_interest_amount",
          message: "No equity interest amount"
        }
      end

      if @data_store.data["total_savings_distribute"].to_f.round(2) == 0.00
        @errors[:messages] << {
          key: "total_savings_distribute",
          message: "No savings distribute amount"
        }
      end

      if @data_store.data["total_cbu_distribute"].to_f.round(2) == 0.00
        @errors[:messages] << {
          key: "total_cbu_distribute",
          message: "No cbu distribute amount"
        }
      end

      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end

      @errors
    end
  end
end
