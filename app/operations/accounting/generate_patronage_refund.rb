module Accounting
  class GeneratePatronageRefund
    def initialize(start_date:, end_date:, patronage_rate:, branch_id:)
      @data = {}
      @data[:details] = []
      @patronage_rate = (patronage_rate / 100)
      @start_date = start_date.to_date
      @end_date = end_date.to_date
      member_status = ["active","resigned"]
      @member = Member.where("branch_id = ? and status IN (?)",branch_id, member_status)
      #@member = Member.find("4efaa853-2e66-42f9-be88-4aa89798c90b")
        
    
    end
      
    def execute!
      z = {}
      z[:final_count] = []
      z[:grand_total] = []
      z[:grand_total_savings] = []
      z[:grand_total_cbu] = []
      #member = @member
      @member.each do |member|
      #if member
        tmp                   = {}
        tmp[:member_id]       = member.id
        tmp[:member_name]     = member.full_name
        tmp[:patronage_reate] = @patronage_rate
        tmp[:details]         = []
        loans                 = Loan.where("member_id = ? and status IN (?)", member.id, ["active","paid"])
        start_date_details    = @start_date

        while(start_date_details <= @end_date) do
          d                   = {}
          start_date_month    = start_date_details.month
          start_date_year     = start_date_details.year
          d[:month]           =  start_date_month
          d[:month_in_words]  =  Date::MONTHNAMES[start_date_details.month]
          d[:loan_details]    = []
          loans.each do |l|
            lDetails            = {}
            lDetails[:loan_id]  = l.id
            lDetails[:payment]  = []
            at  =  AccountTransaction.where(
                                          "subsidiary_id = ? and 
                                           extract(month from transacted_at) = ? and 
                                           extract(year from transacted_at) = ? and 
                                           status = ?", 
                                           l.id,
                                           start_date_month, 
                                           start_date_year,
                                           "approved")
            at.each do |a|
              atDetails           = {}
              atDetails[:amount]  = a.data.with_indifferent_access[:total_interest_paid]
              lDetails[:payment]  << atDetails
            end

            jef               = lDetails[:payment].sum{ |x| x[:amount].to_f}
            lDetails[:month_total_amount] = jef 
            d[:loan_details]  << lDetails

          end
          d[:sample] = d[:loan_details].sum{ |x| x[:month_total_amount].to_i }
        
          tmp[:details]       << d
          start_date_details  = start_date_details + 1.month
        end
        
        
        tmp[:total_member_interest]   = ( tmp[:details].sum{ |d| d[:sample].to_f} ).round(2)
        tmp[:member_interest_average] = (tmp[:total_member_interest] * @patronage_rate).round(2)
        tmp[:member_savings_total]    = (tmp[:member_interest_average] * 0.9).round(2)
        tmp[:member_cbu_total]        = (tmp[:member_interest_average] * 0.1).round(2)
        
        savings_cbu_total = tmp[:member_savings_total] + tmp[:member_cbu_total]
        if savings_cbu_total > tmp[:member_interest_average]
          tmp[:member_gtotal] = savings_cbu_total
        else
          tmp[:member_gtotal] = tmp[:member_interest_average]
        end
        z[:final_count] << tmp
    
        

      end
      

      
       z[:total_interest]       = z[:final_count].sum{ |s| s[:total_member_interest] }.round(2)
       z[:grand_total]          = z[:final_count].sum{ |s| s[:member_gtotal] }.round(2)
       z[:grand_total_savings]  = z[:final_count].sum{ |s| s[:member_savings_total] }.round(2)
       z[:grand_total_cbu]      = z[:final_count].sum{ |s| s[:member_cbu_total] }.round(2)
       @data[:details] << z

      @data
    end
    
  end
end
