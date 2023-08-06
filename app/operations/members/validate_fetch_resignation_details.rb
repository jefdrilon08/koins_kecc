module Members
  class ValidateFetchResignationDetails < AppValidator
    def initialize(config:)
      super()
      
      @config = config

      @member = @config[:member]
      @user   = @config[:user]
      @resignation_settings     = Settings.resignation
      @share_capital = MemberAccount.where(account_type: "EQUITY",account_subtype: "Share Capital",member_id: @member.id).first.balance.to_f
      @cbu = MemberAccount.where(account_type: "EQUITY",account_subtype: "CBU",member_id: @member.id).first.balance.to_f
      @mm_rec=MembershipPaymentRecord.where("member_id = ? and membership_name = ? and status = ? ", "#{@member.id}","K-KOOP","paid").last
      @closing_fee                  = @resignation_settings.closing_fee
      @number_of_years              = @resignation_settings.number_of_years
      @total_equity_balance = 0.0

    end

    def execute!
      a = []
      Loan.where(member_id: @member.id).each do |g|
        if g.data.with_indifferent_access[:accrued_interest].present?
          if g.data.with_indifferent_access[:accrued_interest]["status"] != "remove"
            a << g.data.with_indifferent_access[:accrued_interest][:total_accrued_interest].to_f - g.data.with_indifferent_access[:accrued_interest][:total_accrued_interest_balance].to_f
          end
        end
      end

      
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member not found."
        }
      elsif !@member.active?
        @errors[:messages] << {
          key: "member",
          message: "Member is not active."
        }
      else
        active_loans  = Loan.active.where(member_id: @member.id)
        total_active_loans = active_loans.count
        total_balance = 0.0
        matured_loans_counts = 0

        #check years of membership
        @closing_date = @mm_rec.date_paid + @number_of_years.years
        if DateTime.now.to_date < @closing_date
          @share_capital = @share_capital - 100.0
        end

        if active_loans.any?  
          active_loans.each do |o|
            
            #check if the loan is matured and count it 

            if o.maturity_date.to_date < Date.today
              matured_loans_counts += 1
            end

            #sum up all active loan balances
            total_balance += o.total_balance.to_f
          end
        end

        #add total balance of accrued
        if a.any?
          total_balance += a.sum
        end

        if @share_capital.to_f >= total_balance.to_f
          @total_equity_balance = @share_capital.to_f
        else
          @total_equity_balance = (@share_capital + @cbu.to_f).round(2).to_f
        end
        #raise "if #{@total_equity_balance.round(2).to_f} > #{total_balance.to_f.inspect} ".inspect

        #check if all active loans are matured and share capital balance is equal to all loan balances


              

        if a.any? and total_active_loans == 0
          if @total_equity_balance.to_f < total_balance.to_f
            @errors[:messages] << {
              key: "member",
              message: "Member have a total #{a.sum.round(2)} accrued interest to pay and Total Equity Balance is not enough"
            }
          end
        elsif a.any? and total_active_loans > 0 
          if total_active_loans > matured_loans_counts
            active_loans.each do |o|
              @errors[:messages] << {
                key: "loan_#{o.id}",
                message: "Active loan balance for #{o.loan_product.to_s}: #{o.total_balance} and Maturity Date: #{o.maturity_date.to_date.strftime("%B %d, %Y")}"
              } 
            end

          elsif total_active_loans == matured_loans_counts and @total_equity_balance < total_balance
             active_loans.each do |o|
               @errors[:messages] << {
                  key: "loan_#{o.id}",
                  message: "All Active loans are Matured but the Total Equity Balance is not enough"
                } 
            end
          end
        elsif a.nil? and total_active_loans > 0
          if total_active_loans > matured_loans_counts
             active_loans.each do |o|
              @errors[:messages] << {
                key: "loan_#{o.id}",
                message: "Active loan balance for #{o.loan_product.to_s}: #{o.total_balance} and Maturity Date: #{o.maturity_date.to_date.strftime("%B %d, %Y")}"
              } 
            end
          elsif total_active_loans == matured_loans_counts and @total_equity_balance < total_balance
             @errors[:messages] << {
                key: "loan_#{o.id}",
                message: "All Active loans are Matured but the Total Equity Balance is not enough"
              } 
          end
        end

     


          








        # if  total_active_loans.to_i > matured_loans_counts.to_i or @total_equity_balance.to_f < total_balance.to_f 

        #   if a.any? and total_active_loans.to_i > matured_loans_counts.to_i 
        #     @errors[:messages] << {
        #       key: "member",
        #       message: "Member have a total #{a.sum.round(2)} accrued interest to pay"
        #     }
        #   end
          
     
        # end


      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User not foud"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end

      @errors
    end
  end
end
