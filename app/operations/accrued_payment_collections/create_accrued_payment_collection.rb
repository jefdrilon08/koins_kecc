module AccruedPaymentCollections
  class CreateAccruedPaymentCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      @user             = @config[:user]
      @branch           = @config[:branch_id]
      @center           = @config[:center_id]

      @accrued_payment_collection  = AccruedBilling.new(
                                          collection_date: @collection_date,
                                          branch_id: @branch,
                                          center_id: @center
                                        )
      @data = {
        or_number: "",
        ar_number: "",
        records: [],
        headers: [],
        totals: [],
        total_collected: 0.00
      }
    end

    def execute!
      @accrued_payment_collection.data = @data
      @accrued_payment_collection.save!
    end
  end
end
