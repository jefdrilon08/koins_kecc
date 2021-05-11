module BillingForFullPayments
  class CreateBillingForFullPayments
   
   def initialize
    
   end
   
   def execute!
      
      x = []
      get_billing_header.each do |gbh|
        x << Loan.where(member_id: "875046aa-3009-441c-a04b-6f53ce94fa5b", loan_product_id: gbh)
      end
   end
   private

   def get_billing_header
      @billing_header = []
      Settings.loan_products.each do |a|
        if  a[:for_unearned_interest] == true
          @billing_header << a[:loan_product_id]
        end
      end
      @billing_header

   end

  

  end
end
