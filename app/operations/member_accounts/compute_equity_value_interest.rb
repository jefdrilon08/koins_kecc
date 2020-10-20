module MemberAccounts
  class ComputeEquityValueInterest
    def initialize(member_account:)

      @member_account       = member_account
      @implementation_date  = "2019-01-01".to_date
      @current_date         = Date.today
      @x_interest           = 0.000833333333333

      @transactions         = AccountTransaction.savings.where(
                                "subsidiary_id = ? AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
                                @member_account.id,
                                @implementation_date,
                                @current_date
                              ).order("transacted_at ASC, created_at ASC")

      @transacted_at_dates  = @transactions.pluck(:transacted_at)
    end

    def execute!
      @finish_date = []

      @transacted_at_dates.sort.each do |t_date|

        @beginning_of_month = t_date.to_date.beginning_of_month
        @end_of_month       = t_date.to_date.end_of_month

        if !@finish_date.map(&:to_date).any? @beginning_of_month
          @latest_transaction = @transactions.where(
                                  "DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
                                  @beginning_of_month,
                                  @end_of_month
                                ).order("transacted_at ASC, created_at ASC").last

          if !@latest_transaction.nil?
            @latest_transaction_data = @latest_transaction.data.with_indifferent_access
          end

          if @latest_transaction_data.present?
            @interest = ((@latest_transaction_data[:ending_balance].to_f / 2) * @x_interest).round(2)
            @latest_transaction_data[:equity_value_interest] = @interest
            @latest_transaction.update!(data: @latest_transaction_data)

            # PAGCOMPUTE NG TOTAL INTEREST SA MEMBER ACCOUNT NA LIFE
            # total_equity_interest = AccountTransaction.where("subsidiary_id = ?", member_account.id).sum("CAST(data->>'equity_value_interest' AS decimal)").to_f
          end

          @finish_date << @beginning_of_month
        end
      end
    end
  end
end
