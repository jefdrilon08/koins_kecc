module InvoluntaryPayment
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
      enabled_loans = @record.select { |y| y[:enabled] == true }
      @header.each do |hd|
        @total_amount = []
        @total_principal = []
        @total_interest = []
        enabled_loans.each do |el|
          loan_data = el['loan_data'].select { |u| u['name'] == hd[:name] }.last
          if loan_data
            @total_amount << loan_data[:amount].to_f
            @total_principal << loan_data[:principal_amount].to_f
            @total_interest << loan_data[:interest_amount].to_f
          end
        end
        hd[:total_amount] = @total_amount.sum.to_f
        hd[:principal_amount] = @total_principal.sum.to_f
        hd[:interest_amount] = @total_interest.sum.to_f
      end
    end

    def update_total_payment!
      total_payment = @header.sum { |tot_amount| tot_amount['total_amount'].to_f }
      @data[:total_payment] = total_payment
    end

    def update_total_cash_payment!
      @data[:total_cash_payment] = @data[:total_payment]
    end

    def execute!
      update_total_amount!
      update_total_payment!
      update_total_cash_payment!
      @data_store.update(data: @data)
    end
  end
end