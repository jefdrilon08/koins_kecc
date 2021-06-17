module BillingForFullPayments
  class SaveBillingForFullPayments
    def initialize(config:)
      
      @config = config
      @data_store       = DataStore.new
      @due_date = @config[:collection_date]
      @branch_id = @config[:branch]
      @center_id = @config[:center]
      @data_store_type = "BILLING FOR FULL PAYMENT"


      @meta = {
        collection_date: @due_date,
        branch_id: @branch_id,
        center_id: @center_id,
        data_store_tpe: @data_store_type
      
      }



    end
    def execute!
          config = {
            branch: @branch_id,
            center: @center_id,
            collection_date: @due_date

          }
          @record = ::BillingForFullPayments::CreateBillingForFullPayments.new(
                                                                                config: config
                                                                              ).execute!


          @data_store.meta = @meta
          @data_store.data = @record
          @data_store.status = "pending"

          @data_store.save!

          


          
    end
  end
end
