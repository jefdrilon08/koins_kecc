module Dormants
  class UpdateAmount
    def initialize(config:)
      @config           = config
      @data_store_id    = @config[:data_store_id]
      @member_id        = @config[:member_id]
      @payment_amount   = @config[:payment_amount]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @member           = @data[:record].select{|x| x["member_id"] == @member_id}.last
      @member_data      = @member['loan_data']
    end

    def update_withdraw_payment!
      withdraw_data = @member_data.select{|z| z["name"] == "Withdraw Payment"}.last
      withdraw_data['amount'] = @payment_amount.to_f
    end

    def update_total_payment_per_member!
      member_data              = @member_data.select{|md| md["name"] != "Withdraw Payment"}
      total_amount             = member_data.sum { |tot_amount| tot_amount['amount'].to_f}
      @member['total_payment'] = total_amount.to_f
    end

    def update_total_cash_payment_per_member!
      wp_amount                     = @member['loan_data'].select{|wp| wp["name"] == "Withdraw Payment"}.last['amount'].to_f
      total_cash_payment            = @member['total_payment'] - wp_amount
      @member['total_cash_payment'] = total_cash_payment.to_f
    end

    def execute!
      update_withdraw_payment!
      update_total_payment_per_member!
      update_total_cash_payment_per_member!
      @data_store.update(data: @data)
    end
  end
end
