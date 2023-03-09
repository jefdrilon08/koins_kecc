module Accounting
  class GeneratePatronageRefund
    attr_accessor :data, :result
    def initialize(config:)
      @config = config
      @year   = @config[:year]
      @branch = @config[:branch]

      @data = {
        year: @year,
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        
        patronage_interest_rate: 0.00,
        savings_rate: 0.00,
        cbu_rate: 0.00,
        status: "pending",
        total_interest_paid_amount: 0.00,
        ave_interest: 0.00,
        total_savings_distribute: 0.00,
        total_cbu_distribute: 0.00,
        records: []
      }
    end
      
    def execute!
    query!

    
    @data[:records] = @result.map{ |o|

                          temp  = {
                            id: o.fetch("member_id"),
                            first_name: o.fetch("first_name"),
                            middle_name: o.fetch("middle_name"),
                            last_name: o.fetch("last_name"),
                            identification_number: o.fetch("identification_number"),
                            status: o.fetch("member_status"),
                            center: {
                              id: o.fetch("center_id"),
                              name: o.fetch("center_name")
                            },

                            branch: {
                              id: @branch.id,
                              name: @branch.name
                            },
                            
                            months: [],
                            total_interest_paid_amount: 0.00,
                            ave_interest: 0.00,
                            patronage_interest_amount: 0.00,
                            savings_distribute: 0.00,
                            cbu_distribute: 0.00
                          }

                          (1..12).to_a.each do |m|
                            d = {
                              month_index: m,
                              month: Date::MONTHNAMES[m],
                              year: @year,
                              amount: 0.00
                            }
                            # loan_id = Loan.where(id: "b6d98dc7-4c9c-4f16-a6f8-972740b9a867")
                            loan_id= Loan.select("id, 
                              date_approved").where("member_id = '#{o.fetch('member_id')}' AND status IN ('active','paid','writeoff') and extract(year from date_approved) <= '#{@year}'" 
                              )
                                      temp_dates= {}
                                      temp_dates[:months]= []
                                      (1..12).to_a.each do |m_p|
                                        dates = {
                                          month_index: m_p,
                                          month: Date::MONTHNAMES[m_p],
                                          year: @year,
                                          amount: 0.00
                                        }
                                        #raise loan_id.to_a.count.inspect 
                                              loan_id.each do |loan_ids| 

                                                  at_month= AccountTransaction.where("extract(year from transacted_at) = '#{@year}' 
                                                      AND extract(month from transacted_at) = '#{dates[:month_index]}'
                                                      AND status= 'approved' 
                                                      AND transaction_type= 'loan_payment'
                                                      AND subsidiary_id= '#{loan_ids.id}'")
                                                      
                                                      at_month.each do |acc_trans|

                                                        if dates[:month_index] == acc_trans[:transacted_at].month
                                                        dates[:amount] += acc_trans[:data]["total_interest_paid"].to_f.round(2)
                                                        else
                                                          dates[:amount] += 0.0
                                                        end
                                                      end
                                              
                                              end #end of loan_id
                                              temp_dates[:months] << dates
                                      end #end of 2nd 1..2
                            temp_dates[:months].each do |td|
                              if td[:month_index] == d[:month_index]
                                 d[:amount] = td[:amount]
                              end
                            end

                              
                            temp[:months] << d

                          end #end of 1..12
                          
                           temp[:total_interest_paid_amount] = temp[:months].inject(0){ |sum, hash| sum + hash[:amount] }.to_f.round(2)
                          #raise temp[:total_interest_paid_amount].inspect
                           temp[:ave_interest]   = (temp[:total_interest_paid_amount] / 12).round(2)
                          temp

    }
                        
                       @data
       
       @data
    end
    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
      SELECT DISTINCT ON(members.id, members.identification_number)
                members.id AS member_id,
                members.first_name,
                members.middle_name,
                members.last_name,
                members.status AS member_status,
                members.identification_number,
                members.status AS status,
                centers.id AS center_id,
                centers.name AS center_name
                FROM members  
                INNER JOIN centers ON centers.id = members.center_id AND members.branch_id = '#{@branch.id}' AND members.status IN ('active','resigned','cleared','pending','transferred','archived','writeoff')  
                ORDER BY  members.identification_number
      EOS
    end
  end
end
