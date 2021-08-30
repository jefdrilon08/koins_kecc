module BillingForFullPayments
  class CreateBillingForFullPayments
   
   def initialize(config: )
  
    @config = config
    @due_date = @config[:collection_date]
    @branch_id = @config[:branch]
    @center_id = @config[:center]
    
   end
   
   def execute!
    query!
    a = @result.map{ |o|

        
          temp = {
            member_id: o.fetch("member_id"),
            member_last_name:  o.fetch("member_last_name"),
            center: {
              id: o.fetch("center_id"),
              name: o.fetch("center_name")
            },
            balance: [],
            status: "pending"

          }

        
          get_billing_header.each do |gbh|   
            loan = Loan.where(member_id: temp[:member_id] , status: "active", loan_product_id: gbh )
            
            if loan.present?
              d = {
                    member: temp[:member_last_name],
                    record_type: "LOAN PAYMENT",
                    enabled: false,
                    member_account_id: nil,
                    loan_id: loan.last.id,
                    loan_product_id: gbh,
                    principal_balance: 0.0,
                    interest_balance: 0.0,
                    amount: 0.0
                  }
              temp[:balance] << d
              
            else
              d = {
                    member: temp[:member_last_name],
                    record_type: "LOAN PAYMENT",
                    enabled: false,
                    member_account_id: nil,
                    loan_id: nil,
                    loan_product_id: gbh,
                    principal_balance: 0.0,
                    interest_balance: 0.0,
                    amount: 0.0
                  }
              temp[:balance] << d

            end
            
              
          
          end
          temp[:balance] << { 
                                record_type: "WP",
                                enabled: true,
                                amount: 0.0,
                                member_account_id: MemberAccount.where(member_id: temp[:member_id], account_subtype: "K-IMPOK" ).last.id
                              }
          temp


    }
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

      #raise @billing_header.inspect

   end

  def query!
    @result =  ActiveRecord::Base.connection.execute(<<-EOS).to_a
                SELECT DISTINCT ON(member.id)
                  member.id as member_id,
                  member.last_name as member_last_name,
                  member.first_name as member_first_name,
                  loan.id as loan_id,
                  loan.loan_product_id as product_id,
                  lp.name as product_name,
                  loan.principal_balance as loan_principal_balance,
                  loan.interest_balance as loan_interest_balance,
                  center.id as center_id,
                  center.name as center_name
                FROM
                  Loans as loan
                INNER JOIN Members as member on loan.member_id = member.id
                INNER JOIN Centers as center on member.center_id = center.id
                INNER JOIN Loan_products as lp on loan.loan_product_id = lp.id
                WHERE loan.status = 'active' and loan.center_id = '#{@center_id}'
               EOS
  end

  

  end
end
