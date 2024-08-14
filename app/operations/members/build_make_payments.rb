module Members
  class BuildMakePayments
    def initialize(config:)
    #def initialize
      @config = config
      @member_id = @config[:member_id]
      @make_payment_type = @config[:make_payment_type]
      @member = Member.find(@member_id)
      #@member_id = "066b697f-df51-42b9-a250-ec0dbac6722f"

      if @member.member_type == "GK" 
        
        @loan = Loan.joins(:loan_product).where("loans.member_id = ? and status = ?", @member_id, "active")
      else
        if @make_payment_type == "CLIP"
          @loan = Loan.joins(:loan_product).where("loans.member_id = ? and loan_products.insured is true and status = ?", @member_id, "active")
        else
          @loan = Loan.joins(:loan_product).where("loans.member_id = ? and loan_products.insured is false and loans.status = ?", @member_id, "active")
        end
      end

     

      @data = {
          member_id: @member_id,
          meta: {
                  book: "CRB",
                  or_number: "",
                  si_number: "",
                  ar_number: "",
                  particular: ""
                },
          records: [],
          status:  "pending"

      }
    end
    def execute!
      
      @loan.each do |l|
         
          tmp = {
              loan_id: l.id,
              record: [],
              total_principal_balance: 0.0,
              total_interest_balance: 0.0

          }  
        
        loan_amort = AmortizationScheduleEntry.where("loan_id = ? and is_paid is null", l.id).order(:due_date)
        a =  loan_amort.map{ |amort| {due_date: amort.due_date.strftime('%F'), amount: amort.principal_balance.to_f, interest_amount: amort.interest_balance.to_f}  }.to_a
        @g = a.group_by {|v| Date.parse(v[:due_date][0,7] + '-01') }.sort
        @range = @range = Date.new(loan_amort.first.due_date.strftime('%Y').to_i,loan_amort.first.due_date.strftime('%m').to_i)..Date.new(loan_amort.last.due_date.strftime('%Y').to_i,loan_amort.last.due_date.strftime('%m').to_i)
        
        h = Hash[@g]
        tmp[:record] = @range.to_a.map {|d| Date.new(d.year,d.month,1)}.uniq.map { |d| 
                                                                      {
                                                                        principal_balance: h[d].try(:reduce, 0) {|sum,h| sum + h[:amount]} || 0, 
                                                                        interest_balance: h[d].try(:reduce, 0) {|sum,h| sum + h[:interest_amount]} || 0, 
                                                                        month:  d.strftime('%^B'),
                                                                        year: d.strftime('%Y')
                                                                      } 
                                                                }
        tmp[:total_principal_balance] = tmp[:record].sum{ |g| g[:principal_balance]  }
        tmp[:total_interest_balance]  = tmp[:record].sum{ |g| g[:interest_balance]  }
        @data[:records] << tmp
        
      end
      
      @data
      
    
    end
  end
end
