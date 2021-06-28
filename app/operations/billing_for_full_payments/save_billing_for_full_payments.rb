module BillingForFullPayments
  class SaveBillingForFullPayments
    def initialize(config:)
      
      @config = config
      @data_store       = DataStore.new
      @due_date = @config[:collection_date]
      @branch_id = @config[:branch]
      @center_id = @config[:center]
      @data_store_type = "BILLING FOR FULL PAYMENT"





    end
    def execute!
      @meta = {
        collection_date: @due_date,
        branch_id: @branch_id,
        center_id: @center_id,
        data_store_tpe: @data_store_type,
        header: []
      
      }



          config = {
            branch: @branch_id,
            center: @center_id,
            collection_date: @due_date

          }
          @record = ::BillingForFullPayments::CreateBillingForFullPayments.new(
                                                                                config: config
                                                                              ).execute!
      
          
          @data_store.meta = @meta
          @get_billing_header = get_billing_header
          @get_billing_header << "WP"
          @data_store.meta["header"] << @get_billing_header
          @data_store.data = @record
          @data_store.status = "pending"

          @data_store.save! 
    end
    

    def get_billing_header
      @billing_header = []
      Settings.loan_products.each do |a|
        if  a[:for_unearned_interest] == true
          @billing_header << a[:loan_product_id]
        end
      end
      @billing_header

      #raise @billing_header.inspect

   end
  end
end
