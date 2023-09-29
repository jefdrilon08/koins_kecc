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
      @@accounting_entry = @data[:accounting_entry]
      #@accrued_loan = Loan.where("branch_id = ? and member_id = ? and data ->> 'accrued_interest' IS NOT NULL" , @branch_id, @member.id)


     
    end
    def execute!

      add_member!

      @data[:records].each do |rec|

        @loan_balance = rec[:member][:total_loan_balances].to_f
        @savings_balance = rec[:member][:total_savings_balances].to_f
        @equity_balance = rec[:member][:total_equity_balances].to_f
        @total_member_account_balances = (@savings_balance + @equity_balance).to_f.round(2)
       
        if @loan_balance == @total_member_account_balances
          #raise "sapat".inspect
        else
          loan_rec = rec[:member][:loan_records]
          if loan_rec.count > 1 
            loan_rec_sort =  loan_rec.sort_by{ |date| date[:maturity_date]}
            loan_to_paid = Loan.find(loan_rec_sort.first[:loan_id])


            if loan_to_paid.total_balance < @total_member_account_balances
              #raise "true".inspect
            else
              principal_to_paid = loan_to_paid.principal_balance
              interest_to_paid = loan_to_paid.interest_balance

              @total_member_account_balances = @total_member_account_balances.to_f - interest_to_paid.to_f
              @total_member_account_balances = @total_member_account_balances.to_f - principal_to_paid.to_f

              #raise @total_member_account_balances.to_f.inspect
            end

          else
            raise loan_rec.inspect
          end
        end

      end
      

    

      raise @data[:records].inspect


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
