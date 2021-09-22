module BillingForFullPayments
  class SaveBillingForFullPayments
    def initialize(config:)
      
      @config = config
      @data_store       = DataStore.new
      @due_date = @config[:collection_date]
      @branch_id = @config[:branch]
      @center_id = @config[:center]
      @data_store_type = "BILLING FOR FULL PAYMENT"
      
      @particular   = default_particular




    end
    def execute!
      @meta = {
        collection_date: @due_date,
        branch_id: @branch_id,
        center_id: @center_id,
        data_store_type: @data_store_type,
        header: [],
        data: {
                OR: "",
                AR: "",
                particular: @particular
        }
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
          @get_billing_header << {
                                  loan_product:  "WP",
                                  receivable_amount: 0.0,
                                  interest_receivable_amount: 0.0,
                                  amount: 0.0
                                  }
          #@get_billing_accounting_details = {
          #                        OR: "",
          #                        AR: "",
          #                        particular: @particular ,
          #                        }
          @data_store.meta["header"] << @get_billing_header
          #@data_store.meta["data"] << @get_billing_accounting_details
          @data_store.data = @record
          @data_store.status = "pending"

          @data_store.save! 
    end
    

    def get_billing_header
      @billing_header = []
      Settings.loan_products.each do |a|
        if  a[:for_unearned_interest] == true
          header_entry = {
            loan_product: a[:loan_product_id],
            receivable_accounting_code_id: a[:receivable_accounting_code_id],
            interest_receivable_accounting_code_id: a[:interest_receivable_accounting_code_id],
            receivable_amount: 0.0,
            interest_receivable_amount: 0.0

          }
          @billing_header << header_entry
        end
      end
      @billing_header

      #raise @billing_header.inspect

   end



    def default_particular
      "Payment of Loan"
    end
  end
end
