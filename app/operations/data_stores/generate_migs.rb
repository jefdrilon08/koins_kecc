module DataStores
  class GenerateMigs
    attr_accessor :data, :result


          def initialize(config:)
            @config         = config
            @current_year   = @config[:year] 
            @branch         = @config[:branch]
            @migs_year      = @current_year.to_i - 1
            #get the Last Repayment Rate last year (current_year - 1)
            @repayment_rates = DataStore.repayment_rates.where("meta->>'branch_id' = ? 
                                             and EXTRACT('year' from as_of )= ?",
                                             "#{@branch.id}","#{@migs_year}").order("as_of DESC").first
           
            @data = {
              year: @current_year,
              branch: {
                id: @branch.id,
                name: @branch.name
              },
              records: [],
              migs_as_of: @migs_year
            }
          end

          def execute!
            query!
            data_records = @result.map{|o|
                                 temp= {
                                    id:          o.fetch("member_id"),
                                    first_name:  o.fetch("first_name"),
                                    last_name:   o.fetch("last_name"),
                                    middle_name: o.fetch("middle_name"),
                                    identification_number: o.fetch("identification_number"),
                                    center: JSON.parse(o.fetch("center")),
                                    officer: JSON.parse(o.fetch("officer"))
                                 }
                                 temp
                           }
            data_r = data_records.uniq{|hash| hash.values_at(:id)}
            @data[:records]= data_r
            @data

          end
          def query!
            sql = "SELECT   
            arr->'member'->>'id' as member_id ,
            arr->'member'->>'first_name' as first_name, 
            arr->'member'->>'last_name' as last_name, 
            arr->'member'->>'middle_name' as middle_name,
            arr->'member'->>'identification_number' as identification_number , 
            arr->'id' as loan_id,
            arr->'loan_product'->>'name' as loan_product,
            arr->'total_balance' as total_loan_balance, 
            arr->>'num_days_par' as num_day_par,
            arr->>'total_rr' as total_rr,
            arr->'center' as center , arr-> 'officer' as officer 
            from data_stores,json_array_elements(data->'records') 
            arr(records) where data_stores.id='#{@repayment_rates.id}'  and arr->>'total_balance' = '0.0'
             ORDER BY identification_number,last_name ASC "
            @result = ActiveRecord::Base.connection.execute(sql).to_a
          end     
  end
end