module Members
  class SetMaintainingBalance
    def initialize(config:)
      @config = config
    
      @member = @config[:member]

      @active_loans = Loan.active.where(
                        member_id: @member.id
                      )

  
      @member_accounts  = @member.member_accounts

      @settings_loan_products = Settings.loan_products
    end

    def execute!
      #raise @active_loans.length.inspect
      #if @active_loans == []
      
      #@member_accounts.where(account_subtype: "K-IMPOK").last.update(maintaining_balance: 100.0)
        
      #end
      
      @member_accounts.each do |member_account|
        
        maintaining_balance = 0.00

        if member_account.account_subtype == "Maintaining Balance Savings"
          member_account.update!(maintaining_balance: 0.0)
        end
        
        @settings_loan_products.each do |s|
          
          if s.maintaining_balance.present? and member_account.account_type == s.maintaining_balance.account_type and member_account.account_subtype == s.maintaining_balance.account_subtype
            current_loans = @active_loans.where(loan_product_id: s.loan_product_id)
            
            if member_account.present? and current_loans.any?
              current_loans.each do |loan|
              
                if s.maintaining_balance.threshold.present? and loan.principal >= s.maintaining_balance.threshold.to_f.round(2)
                  
                  #maintaining_balance += (loan.principal_balance * s.maintaining_balance.percentage)
                  maintaining_balance += (loan.principal * s.maintaining_balance.percentage)
                end
              end
              
              mb  = maintaining_balance.to_f.round(2)
                    
              member_account.update!(maintaining_balance: mb)
              
            end
          end
        
        end #settings_loan_products
      

      end #member_accounts
    
      
    end  #def execute
  end
end
