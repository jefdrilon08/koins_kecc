module MemberAccounts
  class ComputeEquityValueInterest
    def initialize(config:)
      @config = config

      @member_account       = @config[:member_account] 
      @month                = @config[:month]
      @year                 = @config[:year]
      @implementation_date  = "2019-01-01".to_date
      @x_interest           = 0.000833333333333

      @last_day_of_month    = Date.new(@year.to_i, @month.to_i, 1).next_month.prev_day
      @beginning_of_month = @last_day_of_month.beginning_of_month

      @latest_transaction   = AccountTransaction.savings.where(
                                "subsidiary_id = ? AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
                                @member_account.id,
                                @beginning_of_month.to_date,
                                @last_day_of_month.to_date
                              ).order("transacted_at ASC, created_at ASC").last 

      if !@latest_transaction.nil?
        @latest_transaction_data = @latest_transaction.data.with_indifferent_access
      end
    end

    def execute!
      if @latest_transaction_data.present?
        if @last_day_of_month > @implementation_date
          @interest = ((@latest_transaction_data[:ending_balance].to_f / 2) * @x_interest).round(2)
          @latest_transaction_data[:equity_value_interest] = @interest
          @latest_transaction.update!(data: @latest_transaction_data)

          # @latest_transaction


          # PAGCOMPUTE NG TOTAL INTEREST SA MEMBER ACCOUNT NA LIFE
          # total_equity_interest = AccountTransaction.where("subsidiary_id = ?", member_account.id).sum("CAST(data->>'equity_value_interest' AS decimal)").to_f
        end
      end
    end
  end
end
