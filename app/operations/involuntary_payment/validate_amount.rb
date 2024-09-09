module InvoluntaryPayment
  class ValidateAmount
    def initialize(config:)
      super()
      @errors           = {messages: []}
      @config           = config
      @data_store_id    = @config[:data_store_id]
      @member_id        = @config[:member_id]
      @loan_id          = @config[:loan_id]
      @payment_amount   = @config[:payment_amount]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @member           = @data[:record].select{|x| x["member_id"] == @member_id}.last
      @member_data      = @member['loan_data']
      @loan_data = @member_data.select{|z| z["loan_id"] == @loan_id}.last
    end
    
    def execute!
      if @loan_data["loan_id"].present?
        if @loan_data["expected_amount"].to_f < @payment_amount.to_f
          @errors[:messages] << {
            key:  "billing",
            message: "payment is larger than writeoff loan balance"
          }
        end 
      end

      if @loan_data["savings_account_id"].present?
        savings_balance = MemberAccount.find(@loan_data["savings_account_id"]).balance.to_f
        if savings_balance < @payment_amount.to_f
          @errors[:messages] << {
            key:  "billing",
            message: "withdraw savings is higher than savings balance"
          }

        end
      end
      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      @errors
    end

  end
end
 