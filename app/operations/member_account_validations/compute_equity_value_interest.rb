module MemberAccountValidations
  class ComputeEquityValueInterest
    def initialize(resignation_date:, member_account:)

      @implementation_date      = "2019-01-01".to_date
      @implementation_date_year = @implementation_date.year
      @x_interest               = 0.000833333333333
      @member_account           = member_account
      
      @resignation_date         = resignation_date.to_date
      @resignation_date_month   = @resignation_date.month
      @resignation_date_year    = @resignation_date.year


      @num_years                = @resignation_date_year - @implementation_date_year
      @months                   = [1,2,3,4,5,6,7,8,9,10,11,12]

      @transactions             = AccountTransaction.savings.where(
                                  "subsidiary_id = ? AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
                                  @member_account.id,
                                  @implementation_date,
                                  @resignation_date
                                ).order("transacted_at ASC, created_at ASC")

      @years                    = []
      while @num_years >= 0
        @years << @implementation_date_year + @num_years
        @num_years = @num_years - 1 
      end

      @interest = []
    end

    def execute!
      @years.sort.each do |year|
        @months.each do |month|
          @last_day_of_month  = Date.new(year, month, 1).next_month.prev_day
          @beginning_of_month = @last_day_of_month.beginning_of_month

          @latest_transaction   = @transactions.where(
                                  "DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
                                  @beginning_of_month.to_date,
                                  @last_day_of_month.to_date
                                ).order("transacted_at ASC, created_at ASC").last 

          if !@latest_transaction.nil?
            @latest_transaction_data = @latest_transaction.data.with_indifferent_access

            if @latest_transaction_data.present?
              @ev_interest = ((@latest_transaction_data[:ending_balance].to_f / 2) * @x_interest).round(2)
              @interest << @ev_interest
            end

            # @latest_transaction_data[:equity_value_interest] = @interest
            # @latest_transaction.update!(data: @latest_transaction_data)

            # @latest_transaction


            # PAGCOMPUTE NG TOTAL INTEREST SA MEMBER ACCOUNT NA LIFE
            # total_equity_interest = AccountTransaction.where("subsidiary_id = ?", member_account.id).sum("CAST(data->>'equity_value_interest' AS decimal)").to_f
          end
        end  
      end    
                
      @interest.sum  
    end
  end
end
