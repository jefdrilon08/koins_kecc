module AccruedPaymentCollections
  class UpdateTransaction
    def initialize(config:)
      @config             = config
      @data_store_id      = @config[:data_store_id]
      @member_id          = @config[:member_id]
      @member_account_id  = @config[:member_account_id]
      @loan_amount        = @config[:loan_amount]
    end

    def execute!
      billing = AccruedBilling.find(@data_store_id)
      billing_data = billing.data.with_indifferent_access
      billing_data[:member_data][@member_id][:loan_data][@member_account_id][:amount] = @loan_amount
      billing.update(data: billing_data)
    end

  end
end
