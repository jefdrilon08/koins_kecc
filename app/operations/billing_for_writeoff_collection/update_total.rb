module BillingForWriteoffCollection
  class UpdateTotal
    def initialize(config:)
      @config           = config
      @data_store_id    = @config[:data_store_id]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access
      @record           = @data[:record]
      @header           = @data[:header]
    end
    
    def update_total_amount!
      enabled_loan = @record.select{|y| y[:enabled] == true}
      @header.each do |hd|
        @total_amount     = []
        @total_principal  = []
        @total_interest   = []
        enabled_loan.each do |el|
          total_amount = el['loan_data'].select{|u| u['name'] == hd[:name] }.last[:amount]
          principal_amount = el['loan_data'].select{|u| u['name'] == hd[:name] }.last[:principal_amount]
          interest_amount = el['loan_data'].select{|u| u['name'] == hd[:name] }.last[:interest_amount]
          @total_amount << total_amount.to_f
          @total_principal << principal_amount.to_f
          @total_interest << interest_amount.to_f
        end
        hd[:total_amount] = @total_amount.sum.to_f
        hd[:principal_amount] = @total_principal.sum.to_f
        hd[:interest_amount] = @total_interest.sum.to_f
      end
    end

    def update_total_payment!
      loan_header           = @header.select{|lh| lh['name'] != "Withdraw Payment"}
      total_payment         = loan_header.sum{ |tot_amount| tot_amount['total_amount'].to_f}
      @data[:total_payment] = total_payment
    end

    def update_total_cash_payment!
      total_wp_amount            = @header.select{|lh| lh['name'] == "Withdraw Payment"}.last['total_amount']
      @data[:total_cash_payment] = @data[:total_payment] - total_wp_amount
    end

    def execute!
      update_total_amount!
      update_total_payment!
      update_total_cash_payment!
      @data_store.update(data: @data)
    end
  
  end
end
 
