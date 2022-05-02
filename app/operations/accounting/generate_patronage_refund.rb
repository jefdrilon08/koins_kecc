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
                            loan_id= Loan.select("id, 
                              date_approved as date_approved").where("member_id = '#{o.fetch('member_id')}' AND status IN ('active','paid','writeoff') and extract(year from date_approved) < '#{@year}'" 
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

                                              loan_id.each do |loan_ids| 
                                                  at_month= AccountTransaction.select(
                                                      "subsidiary_id AS loan_id,
                                                      extract(month from transacted_at) AS month, 
                                                      data->>'total_interest_paid' AS interest_amount, 
                                                      transacted_at").where("extract(year from transacted_at) = '#{@year}' 
                                                      AND extract(month from transacted_at) = '#{dates[:month_index]}'
                                                      AND status= 'approved' 
                                                      AND subsidiary_id= '#{loan_ids.id}'")
                                                      at_month.each do |acc_trans|
                                                        if dates[:month_index] == acc_trans["month"]
                                                        dates[:amount] += acc_trans["interest_amount"].to_f.round(2)
                                                        else
                                                           dates[:amount] += 0.00
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
                           temp[:ave_interest]   = (temp[:total_interest_paid_amount] / 12).round(2)
                          temp

                        }
                        
                       @data
                       
      # z = {}
      # z[:final_count] = []
      # z[:grand_total] = []
      # z[:grand_total_savings] = []
      # z[:grand_total_cbu] = []
      # #member = @member
      # @member.each do |member|
      # #if member
      #   tmp                   = {}
      #   tmp[:member_id]       = member.id
      #   tmp[:member_name]     = member.full_name
      #   tmp[:patronage_reate] = @patronage_rate
      #   tmp[:details]         = []
      #   loans                 = Loan.where("member_id = ? and status IN (?)", member.id, ["active","paid"])
      #   start_date_details    = @start_date

      #   while(start_date_details <= @end_date) do
      #     d                   = {}
      #     start_date_month    = start_date_details.month
      #     start_date_year     = start_date_details.year
      #     d[:month]           =  start_date_month
      #     d[:month_in_words]  =  Date::MONTHNAMES[start_date_details.month]
      #     d[:loan_details]    = []
      #     loans.each do |l|
      #       lDetails            = {}
      #       lDetails[:loan_id]  = l.id
      #       lDetails[:payment]  = []
      #       at  =  AccountTransaction.where(
      #                                     "subsidiary_id = ? and 
      #                                      extract(month from transacted_at) = ? and 
      #                                      extract(year from transacted_at) = ? and 
      #                                      status = ?", 
      #                                      l.id,
      #                                      start_date_month, 
      #                                      start_date_year,
      #                                      "approved")
      #       at.each do |a|
      #         atDetails           = {}
      #         atDetails[:amount]  = (a.data.with_indifferent_access[:total_interest_paid].to_f).round(2)
      #         lDetails[:payment]  << atDetails
      #       end

      #       jef               = lDetails[:payment].sum{ |x| x[:amount].to_f}
      #       lDetails[:month_total_amount] = (jef.to_f).round(2)
      #       d[:loan_details]  << lDetails

      #     end
      #     d[:sample] = d[:loan_details].sum{ |x| x[:month_total_amount].to_f }
        
      #     tmp[:details]       << d
      #     start_date_details  = start_date_details + 1.month
      #   end
        
        
      #   tmp[:total_member_interest]   = (tmp[:details].sum{ |d| d[:sample].to_f} ).round(2)
      #   tmp[:member_interest_average] = (tmp[:total_member_interest] * @patronage_rate).round(2)
      #   tmp[:member_savings_total]    = (tmp[:member_interest_average] * 0.9).round(2)
      #   tmp[:member_cbu_total]        = (tmp[:member_interest_average] * 0.1).round(2)
        
      #   savings_cbu_total = tmp[:member_savings_total] + tmp[:member_cbu_total]
      #   if savings_cbu_total > tmp[:member_interest_average]
      #     tmp[:member_gtotal] = savings_cbu_total
      #   else
      #     tmp[:member_gtotal] = tmp[:member_interest_average]
      #   end
      #   z[:final_count] << tmp
    
        

      # end
      

      
      #  z[:total_interest]       = z[:final_count].sum{ |s| s[:total_member_interest] }.round(2)
      #  z[:grand_total]          = z[:final_count].sum{ |s| s[:member_gtotal] }.round(2)
      #  z[:grand_total_savings]  = z[:final_count].sum{ |s| s[:member_savings_total] }.round(2)
      #  z[:grand_total_cbu]      = z[:final_count].sum{ |s| s[:member_cbu_total] }.round(2)
      #  @data[:details] << z
       
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

     # @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
     #          SELECT DISTINCT ON(members.identification_number,loans.id)
     #            members.id AS member_id,
     #            members.first_name,
     #            members.middle_name,
     #            members.last_name,
     #            members.status AS member_status,
     #            members.identification_number,
     #            members.status AS status,
     #            centers.id AS center_id,
     #            centers.name AS center_name,
     #            loans.id AS loan_id,
     #            loans.date_approved AS date_approved,
     #            loans.status AS loan_status
     #            FROM members
     #            INNER JOIN loans ON loans.member_id = members.id AND loans.status IN ('active','paid') AND members.branch_id = '#{@branch.id}' AND members.status IN ('active','resigned') AND EXTRACT(year FROM loans.date_approved) = '#{@year}'::INT
     #            INNER JOIN centers ON centers.id = members.center_id
     #            ORDER BY  members.identification_number
               

     # EOS
    end
  end
end
