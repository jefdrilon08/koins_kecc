module MemberAccounts
  class ComputeEquityValueInterest
    def initialize(member_account:, start_date:, end_date:)

      @member_account       = member_account
      @start_date           = start_date
      @end_date             = end_date

      @implementation_date  = "2019-01-01".to_date
      @current_date         = Date.today

      if @start_date.nil?
        @start_date         = @implementation_date
      end

      if @end_date.nil?
        @end_date           = @current_date
      end      

      @x_interest           = 0.000833333333333

      @transactions        = trans_by_range(from: @start_date, to: @end_date)

      # @transactions         = AccountTransaction.savings.where(
      #                           "subsidiary_id = ? AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
      #                           @member_account.id,
      #                           @start_date,
      #                           @end_date
      #                         ).order("transacted_at ASC, created_at ASC")

      @transacted_at_dates  = @transactions.pluck(:transacted_at)
    end

    def execute!
      @finish_date = []

      @transacted_at_dates.sort.each do |t_date|

        @beginning_of_month = t_date.to_date.beginning_of_month
        @end_of_month       = t_date.to_date.end_of_month

        if !@finish_date.map(&:to_date).any? @beginning_of_month
          @latest_transaction = @transactions.select{|o| o.transacted_at >=  @beginning_of_month and o.transacted_at <= @end_of_month}.sort_by(&:transacted_at).last

          # @latest_transaction = @transactions.where(
          #                         "DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
          #                         @beginning_of_month,
          #                         @end_of_month
          #                       ).order("transacted_at ASC, created_at ASC").last

          if @latest_transaction.equity_value_interests.count == 0
            
            if !@latest_transaction.nil?
              @latest_transaction_data = @latest_transaction.data.with_indifferent_access
            end

            if @latest_transaction_data.present?
              @interest = ((@latest_transaction_data[:ending_balance].to_f / 2) * @x_interest).round(2)
              
              equity_value_interest = EquityValueInterest.new(
                                                              member_account: @member_account,
                                                              account_transaction: @latest_transaction,
                                                              month_of_year_date: @beginning_of_month,
                                                              interest_amount: @interest
                                                              )

              equity_value_interest.save!

              # @latest_transaction_data[:equity_value_interest] = @interest
              # @latest_transaction.update!(data: @latest_transaction_data)

              # PAGCOMPUTE NG TOTAL INTEREST SA MEMBER ACCOUNT NA LIFE
              # total_equity_interest = AccountTransaction.where("subsidiary_id = ?", member_account.id).sum("CAST(data->>'equity_value_interest' AS decimal)").to_f
            end
          end

          @finish_date << @beginning_of_month
        end
      end
    end

    def trans_by_range(from: nil, to:)
      AccountTransaction.find_by_sql(<<-SQL)
        SELECT id, transaction_type, amount, data, transacted_at, created_at
        FROM account_transactions
        WHERE transaction_type
          IN ('deposit', 'withdraw')
          AND subsidiary_id = '#{@member_account.id}'
          #{"AND transacted_at > '#{from}'" if from}
          AND DATE(transacted_at) <= '#{to}'
        ORDER BY transacted_at ASC, updated_at ASC, created_at ASC
      SQL
    end 
  end
end
