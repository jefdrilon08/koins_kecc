module InvoluntaryPayment
  class UpdateAmount
    def initialize(config:)
      @config           = config
      @data_store_id    = @config[:data_store_id]
      @member_id        = @config[:member_id]
      @loan_id          = @config[:loan_id]
      @payment_amount   = @config[:payment_amount]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @member           = @data[:record].select { |x| x["member_id"] == @member_id }.last
      @member_data      = @member['loan_data']
    end

    def update_member_payment!
      loan_data = @member_data.select { |z| z["loan_id"] == @loan_id }.last
      loan_data['amount'] = @payment_amount.to_f
    end

    def update_total_payment_per_member!
      total_amount = @member_data.sum { |tot_amount| tot_amount['amount'].to_f }
      @member['total_payment'] = total_amount.to_f
    end

    def update_total_cash_payment_per_member!
      total_cash_payment = @member['total_payment']
      @member['total_cash_payment'] = total_cash_payment.to_f
    end

    def update_amort_amount!
      loan_data = @member_data.select { |z| z["loan_id"] == @loan_id }.last
      loan_data[:loan_amort] ||= [] # Ensure loan_amort is initialized as an array

      @amount = @payment_amount.to_f
      loan_data[:loan_amort].each do |o|
        o[:principal_amount] = 0.0.to_f
        o[:interest_amount] = 0.0.to_f
        if @amount > 0.0
          if o[:interest_balance] >= @amount.to_f
            o[:interest_balance] -= @amount.to_f
            o[:interest_amount] = @amount.to_f
            @amount = 0.0
          else
            @amount -= o[:interest_balance].to_f
            o[:interest_amount] = o[:interest_balance].to_f
          end
          if o[:principal_balance] >= @amount.to_f
            o[:principal_balance] -= @amount.to_f
            o[:principal_amount] = @amount.to_f
            @amount = 0.0
          else
            @amount -= o[:principal_balance].to_f
            o[:principal_amount] = o[:principal_balance].to_f
          end
        end
        o[:total_amount] = o[:principal_amount] + o[:interest_amount]
      end
    end

    def update_distribution!
      loan_data = @member_data.select { |z| z["loan_id"] == @loan_id }.last
      loan_data[:loan_amort] ||= [] # Ensure loan_amort is initialized as an array

      loan_data[:principal_amount] = loan_data[:loan_amort].sum { |amort| amort[:principal_amount].to_f }
      loan_data[:interest_amount]  = loan_data[:loan_amort].sum { |amort| amort[:interest_amount].to_f }
    end

    def execute!
      update_member_payment!
      update_total_payment_per_member!
      update_total_cash_payment_per_member!
      update_amort_amount!
      update_distribution!
      @data_store.update(data: @data)
    end
  end
end