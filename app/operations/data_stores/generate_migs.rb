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
            
              @result.select{|o|
                  if o.fetch("total_loan_balance").to_f == 0.0
                  member = Member.find(o.fetch("member_id"))
                  first_name = member.first_name
                  middle_name = member.middle_name
                  last_name = member.last_name
                  identification_num = member.identification_number
                  center = Center.find(member.center_id)
                  center_data = {
                    id: center.id,
                    name: center.name
                  }

                  officer = User.find(center.user_id)
                  officer_data= {
                    id: officer.id,
                    first_name: officer.first_name,
                    last_name: officer.last_name
                  }

                  temp={
                    id: member.id,
                    first_name: first_name,
                    middle_name: middle_name,
                    last_name: last_name,
                    identification_number: identification_num,
                    center: center_data,
                    officer: officer_data
                  }

                  data[:records] << temp
                  end
              }

              @data[:records]= @data[:records].sort_by { |hash| [hash[:center][:name], hash[:last_name]]}
            @data

          end
          def query!
            sql = "SELECT   
            arr->'member'->>'id' as member_id,
            sum((arr->>'total_balance')::float ) as total_loan_balance
            from data_stores,json_array_elements(data->'records') 
            arr(records) where data_stores.id='#{@repayment_rates.id}'  
            group by member_id
            ORDER BY member_id"
            @result = ActiveRecord::Base.connection.execute(sql).to_a
          end     
  end
end