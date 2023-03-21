module DataStores
  class GenerateInvoluntaryMembers
    def initialize(config:)
      @config     = config
      @user       = @config[:user]
      @data_store = DataStore.find(@config[:id])
      @as_of = @data_store.as_of
      @branch_id = @data_store[:meta]["branch_id"]
      @data = @data_store.data.with_indifferent_access
      @number_of_years = 2
      
    end

    def execute!
      query!
      @temp = {
        record: []
      }


      @data_store.data[:record]= @result.map { |o|    
        @loan_records = []
        @member_accounts = []
        loans = Loan.where("member_id = ? and status = ? and maturity_date <= ?","#{o.fetch("member_id")}","active","#{@as_of}")
        member_accounts = Member.find(o.fetch("member_id")).member_accounts
        
        if loans.present?
          loans.each do |ll|
            @loan = Loan.find(ll.id)

            last_loan_payment = AccountTransaction.where(subsidiary_id: ll.id,transaction_type: 'loan_payment', status: "approved").order("transacted_at DESC").pluck(:transacted_at).first

              @loan_records << {
                loan_id: @loan.id,
                loan_product: @loan.loan_product.name,
                principal_balance: @loan.principal_balance.to_f,
                interest_balance: @loan.interest_balance.to_f,
                maturity_date: @loan.maturity_date.to_date,
                status: @loan.status,
                last_loan_payment: last_loan_payment
              }
          end
        end

        member_accounts.each do |mem|
          if mem[:account_subtype] == "K-IMPOK"
            account_transaction = AccountTransaction.where("subsidiary_id = ? and status = ? and data->>'is_interest' = ?  and transaction_type = ?","#{mem.id}","approved","false","deposit").order("transacted_at DESC").first
            if account_transaction.present?
                @kimpok_last_transaction = account_transaction 
                  @member_accounts<< {
                    id: mem[:id],
                    account_subtype: mem[:account_subtype],
                    balance: mem.balance.to_f,
                    last_transaction: @kimpok_last_transaction.transacted_at.to_date
                  }
            end
          elsif mem[:account_subtype] == "Golden K"
             account_transaction = AccountTransaction.where("subsidiary_id = ? and status = ? and data->>'is_interest' = ? and transaction_type = ?","#{mem.id}","approved","false","deposit").order("transacted_at DESC").first
            if account_transaction.present?
                @gk_last_transaction = account_transaction
                  @member_accounts<< {
                      id: mem[:id],
                      account_subtype: mem[:account_subtype],
                      balance: mem.balance.to_f,
                      last_transaction: @gk_last_transaction.transacted_at.to_date
                    }
            end
          end
        end #END MEMBER ACCOUNTS
            if o[:member_type] != "GK"
              if ((@as_of.to_date - @kimpok_last_transaction.transacted_at.to_date).to_i/ 365).to_i >= @number_of_years 
                 
                 temp = {
                      member_id: o.fetch("member_id"),
                      member_name: o.fetch("last_name") + " " + o.fetch("first_name"),
                      identification_number: o.fetch("id_number"),
                      member_status: o.fetch("member_status"),
                      member_type: o.fetch("member_type"),
                      loan_records: @loan_records,
                      member_accounts: @member_accounts
                    }
          
              end
            else
              if ((@as_of.to_date - @gk_last_transaction.transacted_at.to_date).to_i/ 365).to_i >= @number_of_years
                 
                 temp = {
                      member_id: o.fetch("member_id"),
                      member_name: o.fetch("last_name") + " " + o.fetch("first_name"),
                      identification_number: o.fetch("id_number"),
                      member_status: o.fetch("member_status"),
                      member_type: o.fetch("member_type"),
                      loan_records: @loan_records,
                      member_accounts: @member_accounts
                    }
              end
            end
          temp
            
        
      }
      
      @data_store.update(status: "done")
      @data_store
    end


    def query!
            sql = "SELECT DISTINCT ON (members.id,members.identification_number)
                    members.id as member_id,
                    members.identification_number as id_number, 
                    members.first_name as first_name,
                    members.last_name as last_name,
                    members.middle_name as middle_name,
                    members.member_type as member_type,
                    members.status as member_status 
                    from members
                    INNER JOIN loans as loans on members.id = loans.member_id and loans.status = 'active' and loans.maturity_date <= '#{@as_of}'
                    where members.status = 'active' and
                    members.branch_id= '#{@branch_id}' order by members.identification_number "
            @result = ActiveRecord::Base.connection.execute(sql).to_a
          end
  end
end
