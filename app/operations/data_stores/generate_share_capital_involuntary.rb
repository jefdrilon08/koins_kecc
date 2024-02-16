module DataStores
  class GenerateShareCapitalInvoluntary
    def initialize(config:)
      @config     = config
      @user       = @config[:user]
      @data_store = DataStore.find(@config[:id])
      @as_of      = @data_store.as_of
      @branch_id  = @data_store[:meta]["branch_id"]
      @data       = @data_store.data.with_indifferent_access
      
    end

    def execute!
      query!
     
      @data[:records] = @result.map { |o| 
        
        temp = {
          member_id: o.fetch("member_id"),
          member_name: o.fetch("first_name") + o.fetch("last_name") + ", " +o.fetch("middle_name"),
          identification_number: o.fetch("id_number"),
          loans_record: [],
          savings_accounts: [],
          equity_accounts: [],
          insurance_accounts:[]
        }
        member_loans = Loan.where("member_id = ? and status = ? and maturity_date < ?","#{temp[:member_id]}","active","#{@as_of}")
          member_loans.each do |loans|  
            @member_loans = Loan.find(loans.id)
            temp[:loans_record] << {
              loan_id: @member_loans.id,
              loan_product: @member_loans.loan_product.name,
              loan_status: @member_loans.status,
              maturity_date: @member_loans.maturity_date,
              principal_balance: @member_loans.principal_balance.to_f,
              interest_balance: @member_loans.interest_balance.to_f
            }
          end

          member_accounts = Member.find(o.fetch('member_id')).member_accounts
            
            member_accounts.each do |ma|
              if ma.balance.to_f > 0.0
                if ma.account_type == "SAVINGS"
                  temp[:savings_accounts] <<
                  {
                    id: ma.id,
                    account_type: ma.account_type,
                    account_subtype: ma.account_subtype,
                    balance: ma.balance.to_f
                  }
                elsif ma.account_type == "EQUITY"
                  temp[:equity_accounts] << {
                    id: ma.id,
                    account_type: ma.account_type,
                    account_subtype: ma.account_subtype,
                    balance: ma.balance.to_f
                  }
                elsif ma.account_type == "INSURANCE"
                  if ma.account_subtype != "Credit Life Insurance Plan"
                    temp[:insurance_accounts] << {
                      id: ma.id,
                      account_type: ma.account_type,
                      account_subtype: ma.account_subtype,
                      balance: ma.balance.to_f
                    }
                  end
                end
              end
            end

            temp
      }
     
     @data_store.update!(status: "done",data: @data)
     @data_store
    end


    def query!
            sql = "SELECT  DISTINCT ON (members.id,members.identification_number)
                    members.id as member_id,
                    members.identification_number as id_number, 
                    members.first_name as first_name,
                    members.last_name as last_name,
                    members.middle_name as middle_name,
                    members.status as member_status from loans as loans 
                    INNER JOIN members as members on members.id = loans.member_id 
                    where  loans.maturity_date < '#{@as_of}'and loans.status = 'active' and members.branch_id = '#{@branch_id}' order by members.id"
            @result = ActiveRecord::Base.connection.execute(sql).to_a
    end
  end
end
