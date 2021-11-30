module DataStores
  class GenerateForWriteoff
    attr_accessor :data, :result
          def initialize(config:)
            @config         = config
            @year           = @config[:year]
            @number_of_years = @config[:number_years]
            @branch         = @config[:branch]
           
           
            @data = {
              year: @year,
              branch: {
                id: @branch.id,
                name: @branch.name
              },
              records: []
            }
          end

          def execute!
            query!
            
            @data[:records] = @result.map{ |o| 
                      temp =  {
                        id: o.fetch("member_id"),
                        member_id: o.fetch("id_number"),
                        first_name: o.fetch("first_name"),
                        last_name: o.fetch("last_name"),
                        middle_name: o.fetch("middle_name"),
                        member_status: o.fetch("member_status"),
                        loan_id: o.fetch("loan_id"),
                        loan_product: LoanProduct.find(o.fetch("loan_product")).name,
                        principal_balance: o.fetch("principal_balance").try(:round, 2), 
                        interest_balance: o.fetch("interest_balance").try(:round, 2),
                        maturity_date: o.fetch("maturity_date"),
                        loan_status: o.fetch("loan_status"),
                        rsa_id: o.fetch("kimpok_id"),
                        rsa_balance: o.fetch("kimpok").try(:round, 2),
                        psa_id: o.fetch("psa_id"),
                        psa_balance: o.fetch("psa_balance").try(:round, 2),
                        gk_id: o.fetch("gk_id"),
                        gk_balance: o.fetch("gk_balance"),
                        rf_id: o.fetch("rf_id"),
                        rf_balance: o.fetch("rf_balance"),
                        lf_id: o.fetch("lf_id"),
                        lf_balance: o.fetch("lf_balance"),
                        cbu_id: o.fetch("cbu_id"),
                        cbu_balance: o.fetch("cbu").try(:round, 2),
                        equity_id: o.fetch("share_cap_id"),
                        equity_balance: o.fetch("share_cap").try(:round, 2),
                        center: {
                           id: o.fetch("center_id"), 
                           name: o.fetch("center_name")
                        }
                        }
                    temp
            }

            @data[:records] = @data[:records].sort_by { |hash|  hash[:maturity_date]}
            @data

          end

          def query!
            sql = " SELECT  
                    members.id as member_id,
                    members.identification_number as id_number, 
                    members.first_name as first_name,
                    members.last_name as last_name,
                    members.middle_name as middle_name,
                    members.status as member_status,
                    loans.id as loan_id,
                    loans.loan_product_id as loan_product,
                    loans.principal_balance as principal_balance,
                    loans.interest_balance as interest_balance,                
                    loans.maturity_date as maturity_date,
                    loans.status as loan_status,
                    psa.id as psa_id,
                    psa.balance as psa_balance,
                    savings_account.id as kimpok_id,
                    savings_account.balance as kimpok,
                    cbu_account.id as cbu_id,
                    cbu_account.balance as cbu,
                    equity_accounts.id as share_cap_id,
                    equity_accounts.balance as share_cap,
                    gk_account.id as gk_id,
                    gk_account.balance as gk_balance,
                    rf_accounts.id as rf_id,
                    rf_accounts.balance as rf_balance,
                    lf_accounts.id as lf_id,
                    lf_accounts.balance as lf_balance,
                    centers.id as center_id, 
                    centers.name as center_name 
                    from loans as loans 
                    INNER JOIN members as members on members.id = loans.member_id 
                    inner join member_accounts as psa on psa.member_id = members.id and psa.account_subtype = 'Personal Savings Account'
                    inner join member_accounts as savings_account on savings_account.member_id = members.id and savings_account.account_subtype = 'K-IMPOK'
                    inner join member_accounts as cbu_account on cbu_account.member_id = members.id and cbu_account.account_type = 'EQUITY' and cbu_account.account_subtype='CBU'
                    inner join member_accounts as equity_accounts on equity_accounts.member_id = members.id and equity_accounts.account_type = 'EQUITY' and equity_accounts.account_subtype='Share Capital'
                    inner join member_accounts as gk_account on gk_account.member_id = members.id and gk_account.account_type= 'SAVINGS' and gk_account.account_subtype='Golden K'
                    inner join member_accounts as rf_accounts on rf_accounts.member_id = members.id and rf_accounts.account_type= 'INSURANCE' and rf_accounts.account_subtype = 'Retirement Fund'
                    inner join member_accounts as lf_accounts on lf_accounts.member_id = members.id and lf_accounts.account_type= 'INSURANCE' and lf_accounts.account_subtype = 'Life Insurance Fund'
                    inner join centers on centers.id = members.center_id 
                    where Extract('year' from loans.maturity_date) <= (#{@year.to_i - @number_of_years.to_i} ) and
                    loans.status= 'active' and 
                    members.branch_id= '#{@branch.id}' order by maturity_date"
            @result = ActiveRecord::Base.connection.execute(sql).to_a
          end
  end
end