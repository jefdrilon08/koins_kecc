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
      @accounting_entry = @data[:accounting_entry]
      @savings_accounting_codes   = Settings.savings_accounting_codes
      @equity_accounting_codes    = Settings.equity_accounting_codes
      @loan_product_settings      = Settings.loan_product_accounting_codes
      #@accrued_loan = Loan.where("branch_id = ? and member_id = ? and data ->> 'accrued_interest' IS NOT NULL" , @branch_id, @member.id)


     
    end
    def execute!

      add_member!
      @accounting_entry[:debit_journal_entries] = []
      @accounting_entry[:credit_journal_entries] = []
      @accounting_entry[:journal_entries]= []
     
      #create accounting_entry
      journal_entries = []
      @data[:records].each do |rec|

        @loan_balance = rec[:member][:total_loan_balances].to_f
        @savings_balance = rec[:member][:total_savings_balances].to_f
        @equity_balance = rec[:member][:total_equity_balances].to_f
        @total_member_account_balances = (@savings_balance + @equity_balance).to_f.round(2)
       
        if @loan_balance <= @total_member_account_balances
          raise "sapat".inspect
        else
          #hindi sapat ang savings at equity account pambayad sa lahat ng loans
          loan_rec = rec[:member][:loan_records]
          
          #check number of loans
          if loan_rec.count > 1 
            #sort loans by maturity_date
            loan_rec_sort =  loan_rec.sort_by{ |date| date[:maturity_date]}
            #loan that must paid 1st according to maturity_date
            loan_to_paid = Loan.find(loan_rec_sort.first[:loan_id])

            
            #check the first loan matured if loan_balance is < = > to total of the savings + equity
            if loan_to_paid.total_balance < @total_member_account_balances
              raise "sobra ang equity + savings sa unang nagmatured na loan".inspect
            else
              #hindi sapaat ang savings + equity pambayad sa unang nagmatured na loan
              rec[:member][:member_accounts].each do |ma|
                if ma[:balance].to_f > 0.0
                  member_account = MemberAccount.find(ma[:id])
                  if member_account.account_type == "EQUITY"
                    @equity_accounting_codes.each do |eq|
                      if eq.equity_type == member_account.account_subtype
                        accounting_code = AccountingCode.find(eq[:withdrawal_accounting_code_id])
                        @accounting_entry[:credit_journal_entries] << {
                          accounting_code_id: accounting_code.id,
                          code: accounting_code.code,
                          name: accounting_code.name,
                          amount: member_account.balance
                        }  
                      end
                    end
                   
                    
                    
                  elsif member_account.account_type == "SAVINGS"
                    @savings_accounting_codes.each do |sav|
                      if sav.savings_type == member_account.account_subtype
                        accounting_code = AccountingCode.find(sav[:withdrawal_accounting_code_id])
                        @accounting_entry[:credit_journal_entries] << {
                          accounting_code_id: accounting_code.id,
                          code: accounting_code.code,
                          name: accounting_code.name,
                          amount: member_account.balance
                        }  
                      end
                    end
                  end
                end
              end
              
              #loan entries
              @loan_product_settings.each do |lps|
                if lps.loan_product_id == loan_to_paid.loan_product_id
                  principal_accounting_code = AccountingCode.find(lps.receivable_accounting_code_id)
                  interest_accounting_code = AccountingCode.find(lps.interest_receivable_accounting_code_id)


                  if @total_member_account_balances.to_f > loan_to_paid.interest_balance.to_f
                    @accounting_entry[:debit_journal_entries] << {
                      accounting_code_id: interest_accounting_code.id,
                      code: interest_accounting_code.code,
                      name: interest_accounting_code.name,
                      amount: loan_to_paid.interest_balance.to_f
                    }
                    @total_member_account_balances -= loan_to_paid.interest_balance
                    
                  else
                    @accounting_entry[:debit_journal_entries] << {
                      accounting_code_id: interest_accounting_code.id,
                      code: interest_accounting_code.code,
                      name: interest_accounting_code.name,
                      amount: @total_member_account_balances.to_f
                    }
                    @total_member_account_balances = 0.0
                   
                  end

                  if @total_member_account_balances.to_f > 0.0
                    if loan_to_paid.principal_balance.to_f > 0.0
                      @accounting_entry[:debit_journal_entries] << {
                        accounting_code_id: principal_accounting_code.id,
                        code: principal_accounting_code.code,
                        name: principal_accounting_code.name,
                        amount: @total_member_account_balances.to_f
                      }  
                    end
                  end
                
                end
              end
              
              
             
            
            end

          else
            raise loan_rec.inspect
          end
        end

      end
      

    

      @accounting_entry[:debit_journal_entries].each do |adbj|

        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].round(2)
        }
      end

      @accounting_entry[:credit_journal_entries].each do |adbj|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].round(2)
        }
      end

      @accounting_entry
      @data_store[:data] = @data
      @data_store.save!

    end

    def add_member!
      @total_loan_balances = 0.0
      @total_savings_balances = 0.0
      @total_equity_balances = 0.0
      @total_loans    = 0.0
      @total_savings  = 0.0
      @total_equity   = 0.0
      @records = []
      @loanRec = []
      @MemberAccount = []
      

      if @loan_records.present?
        @loan_records.each do |lr|
          @loanRec << {
            loan_id: lr.id,
            loan_product: lr.loan_product.name,
            is_accrued: false,
            principal_balance: lr.principal_balance.to_f,
            interest_balance: lr.interest_balance.to_f,
            principal_balance: lr.principal_balance.to_f,
            interest_balance: lr.interest_balance.to_f,
            total_balance: lr.total_balance.to_f,
            maturity_date: lr.maturity_date
           
          }
          @total_loan_balances += lr.total_balance.to_f
          
        end
      end

      if @member_accounts.present?
        @member_accounts.each do |mr|
          if mr.account_subtype == "K-IMPOK"
            @MemberAccount << {
              id:  mr.id,
              account_subtype:mr.account_subtype ,
              balance: mr.balance.to_f
            }
           @total_savings_balances += mr.balance.to_f 
          elsif mr.account_subtype == "Personal Savings Account"
            @MemberAccount << {
              id: mr.id,
              account_subtype: mr.account_subtype ,
              balance: mr.balance.to_f
            }
            @total_savings_balances += mr.balance.to_f
          elsif mr.account_subtype == "Maintaining Balance Savings"
            @MemberAccount << {
              id: mr.id,
              account_subtype:mr.account_subtype ,
              balance: mr.balance.to_f
            }
            @total_savings_balances += mr.balance.to_f
          elsif mr.account_subtype == "CBU"
            @MemberAccount << {
              id: mr.id,
              account_subtype:mr.account_subtype ,
              balance: mr.balance.to_f
            }
            @total_equity_balances += mr.balance.to_f
          elsif mr.account_subtype == "Share Capital"
            @MemberAccount << {
              id: mr.id,
              account_subtype: mr.account_subtype ,
              balance: mr.balance.to_f
            }
            @total_equity_balances += mr.balance.to_f
          elsif mr.account_subtype == "Golden K"
            @MemberAccount << {
              id: mr.id ,
              account_subtype: mr.account_subtype ,
              balance: mr.balance.to_f
            }
            @total_savings_balances += mr.balance.to_f
          end
        end
      end

      @records = {
        member: {
          member_id: @member.id,
          member_name: @member.full_name,
          center: @member.center.name,
          loan_records: @loanRec,
          member_accounts: @MemberAccount,
          total_loan_balances:  @total_loan_balances,
          total_savings_balances: @total_savings_balances,
          total_equity_balances: @total_equity_balances 

        }

      }
     
      @data[:records] << @records
     
    end

  end
end 
