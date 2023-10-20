module BillingForInvoluntary
  class AddMember
    def initialize(config:)
      @config         = config
      @data_store_id  = @config[:data_store_id]
      @member         = Member.find(@config[:member_id])
      @data_store     = DataStore.find(@data_store_id)
      @branch_id      = @data_store[:meta]["branch_id"]
      @data           = @data_store.data.with_indifferent_access
      @loan_records   = Loan.where(member_id: @member.id, status: "active")
      @member_accounts = MemberAccount.where(member_id: @member.id)
      @savings_accounting_codes   = Settings.savings_accounting_codes
      @equity_accounting_codes    = Settings.equity_accounting_codes
      @resignation_settings         = Settings.resignation
      @closing_fee                  = @resignation_settings.closing_fee
      @number_of_years              = @resignation_settings.number_of_years

      @closing_fee_amount = 0.0
      
    end
    def execute!

      add_member!
      config = {
        records: @data[:records],
        accounting_entry_transfer_savings: @data[:accounting_entry_transfer_savings],
        accounting_entry_loan_payment: @data[:accounting_entry_loan_payments]
      }
      @data[:accounting_entry_transfer_savings] = ::BillingForInvoluntary::BuildAccountingEntryTransferSavings.new(config: config).execute!
      @data[:accounting_entry_loan_payments] = ::BillingForInvoluntary::BuildAccountingEntryLoanPayments.new(config: config).execute!
      
      


      @data_store[:data] = @data
      @data_store.save!

    end

    def add_member!
      @total_loan_balances = 0.0
      @total_savings_balances = 0.0
      @total_equity_balances = 0.0
      memberAccountArr = []
      loanRecArr= []
      if @member_accounts.any?
        @member_accounts.each do |ma|
          member_accounts = MemberAccount.find(ma.id)
          if member_accounts.balance.to_f > 0.0 
            if member_accounts.account_type == "EQUITY" and member_accounts.balance.to_f > 0.0
              memberAccountArr << {
                id: member_accounts.id,
                account_type: member_accounts.account_type,
                account_subtype: member_accounts.account_subtype,
                balance: member_accounts.balance.to_f
              }
              @total_equity_balances += member_accounts.balance.to_f
            elsif member_accounts.account_type == "SAVINGS" and member_accounts.balance.to_f > 0.0
              memberAccountArr << {
                id: member_accounts.id,
                account_type: member_accounts.account_type,
                account_subtype: member_accounts.account_subtype,
                balance: member_accounts.balance.to_f
              }
              @total_savings_balances += member_accounts.balance.to_f
            end
          end
        end
      end

      total_member_account_balance = (@total_savings_balances.round(2) + @total_equity_balances.round(2)).to_f.round(2)
      original_total_member_accoount_balance = total_member_account_balance.to_f
      @total_loan_payment = 0.0
      @remaining_balance = total_member_account_balance.to_f

      loan_rec_sorted = @loan_records.sort_by{ |date| date[:maturity_date]}
      date_of_membership = @member.date_of_membership.to_date + @number_of_years.years
      dt = DateTime.now.to_date
      if dt >= date_of_membership
        @closing_fee_amount = 0.0
      else
        @closing_fee_amount = @closing_fee
        total_member_account_balance -= @closing_fee
      end

      
      loan_rec_sorted.each do |lrs|
        @total_loan_balances += lrs.total_balance.to_f

        #sapat
        if @remaining_balance.to_f >= lrs.total_balance.to_f
          if @remaining_balance.to_f > lrs.interest_balance.to_f
            
            @interest_to_paid = lrs.interest_balance.to_f
            @remaining_balance = @remaining_balance.to_f - lrs.interest_balance.to_f
            @total_loan_payment += @interest_to_paid
            
            if @remaining_balance >= lrs.principal_balance.to_f
              @remaining_balance = @remaining_balance - lrs.principal_balance.to_f
              @principal_to_paid = lrs.principal_balance.to_f
              @total_loan_payment += @principal_to_paid
            elsif @remaining_balance.to_f != 0.0  and @remaining_balance.to_f <= lrs.principal_balance.to_f
              @principal_to_paid = @remaining_balance.to_f
              @remaining_balance = 0.0
              @total_loan_payment += @remaining_balance.to_f
            end

          end
        
          if @interest_to_paid.to_f > 0.0
            loanRecArr << {
              id: lrs.id,
              loan_product: lrs.loan_product.name,
              maturity_date: lrs.maturity_date,
              interest_balance: @interest_to_paid,
              principal_balance: @principal_to_paid
              
            }
         end
        
        
        
        
        
        
        
        
        
        #hindi sapat
        elsif @remaining_balance.to_f < lrs.total_balance.to_f
          
          if @remaining_balance.to_f > lrs.interest_balance.to_f

            @remaining_balance = @remaining_balance - lrs.interest_balance.to_f
            @interest_to_paid = lrs.interest_balance.to_f
            @total_loan_payment += @interest_to_paid
            if @remaining_balance >= lrs.principal_balance.to_f
              @remaining_balance = @remaining_balance - lrs.principal_balance.to_f  
              @principal_to_paid = lrs.principal_balance.to_f
              @total_loan_payment += lrs.principal_to_paid
            
            elsif @remaining_balance.to_f <= lrs.principal_balance.to_f and @remaining_balance.to_f != 0.0  
              @principal_to_paid = @remaining_balance.to_f
              @remaining_balance = 0.0
              @total_loan_payment += @principal_to_paid.to_f
            end
          
          elsif @remaining_balance.to_f <= lrs.interest_balance.to_f
            @interest_to_paid = @remaining_balance.to_f
            @principal_to_paid = 0.0
            @remaining_balance = 0.0
            @total_loan_payment += @interest_to_paid.to_f

          end

          if @interest_to_paid.to_f > 0.0
            loanRecArr << {
              id: lrs.id,
              loan_product: lrs.loan_product.name,
              maturity_date: lrs.maturity_date,
              interest_balance: @interest_to_paid.to_f,
              principal_balance: @principal_to_paid.to_f
            }
          end
        end
        

      
      end
      
        remaining_balance = original_total_member_accoount_balance - @total_loan_payment  
        
      
      @records = {
          member_id: @member.id,
          member_name: @member.full_name,
          center: @member.center.name,
          loan_records: loanRecArr,
          member_accounts: memberAccountArr,
          total_savings: original_total_member_accoount_balance.round(2).to_f,
          total_loan_balances: @total_loan_balances.round(2).to_f,
          remaining_savings: remaining_balance.to_f,
          total_loan_payment: @total_loan_payment.to_f,
          closing_fee_amount: @closing_fee_amount.to_f
      }
     
      
      @data[:records] << @records
     
    end

  end
end 
