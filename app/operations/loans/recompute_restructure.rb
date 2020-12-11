module Loans
  class RecomputeRestructure
    def initialize(config:)
    
        @loan = config[:loan]
        
        @loan_data = @loan.data.with_indifferent_access
        @jef = {}
        @jef[:loan_details] =[]
        @jef[:insurance_details] =[]
    end
    
    def execute!
      @loan_data[:restructured_loans].each do |loan_data|
        
        reg_loan = Loan.find(loan_data[:id])
      
        last_regular_payment = AccountTransaction.where("subsidiary_id =? and transacted_at < ? and status = ? and amount > 0", loan_data[:id], @loan.date_approved,"approved" ).order(:transacted_at).last
        ksagip_payment = AccountTransaction.where("subsidiary_id =?", loan_data[:id]).order(:transacted_at).last
         

        last_regular_payment_data =  last_regular_payment.data.with_indifferent_access

        a = last_regular_payment_data[:amort_entries].sort_by{ |o| o["due_date"]}.last[:due_date]
                 
          if last_regular_payment.transacted_at.to_date <= a.to_date 

            if last_regular_payment.transacted_at.to_date > ksagip_payment.transacted_at.to_date
             #pag walang past due
             
             new_restructure = { id: reg_loan.id,
                              pn_number: reg_loan.pn_number,
                              principal_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              interest_balance: 0.0,
                              total_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              loan_product: {
                                id: reg_loan.loan_product.id,
                                name: reg_loan.loan_product.name
                              }

                            }
              
            else
        
              total_interest = 0
              ksagip_payment.data.with_indifferent_access[:amort_entries].select{ |p| p[:due_date].to_date <= @loan.date_approved.to_date}.each do |kpayment|
                total_interest = total_interest.to_f + kpayment[:interest_paid].to_f
              end
            
              new_restructure = { id: reg_loan.id,
                              pn_number: reg_loan.pn_number,
                              principal_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              k_sagip_interest_balance: total_interest,
                              interest_balance: ksagip_payment.data.with_indifferent_access[:total_interest_paid],
                              total_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid].to_f + total_interest.to_f,
                              loan_product: {
                                id: reg_loan.loan_product.id,
                                name: reg_loan.loan_product.name
                              }

                            }
            end
          else
            
          
            total_interest = 0
            ksagip_payment.data.with_indifferent_access[:amort_entries].select{ |p| p[:due_date].to_date <= @loan.date_approved.to_date}.each do |kpayment|
              total_interest = total_interest.to_f + kpayment[:interest_paid].to_f
            end
            
            new_restructure = { id: reg_loan.id,
                              pn_number: reg_loan.pn_number,
                              principal_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              k_sagip_interest_balance: total_interest,
                              interest_balance: ksagip_payment.data.with_indifferent_access[:total_interest_paid],
                              total_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid].to_f + total_interest.to_f,
                              loan_product: {
                                id: reg_loan.loan_product.id,
                                name: reg_loan.loan_product.name
                              }

                            }
            
            
            
            
            
          end
          

        @jef[:loan_details] << new_restructure
        



      end #end of @loan_data[:restructured_loans]
      
      @jef[:total_principal]  = @jef[:loan_details].inject(0){|sum, x| sum + x[:principal_balance].to_f}
      @jef[:total_interest]   = @jef[:loan_details].inject(0){|sum, x| sum + x[:k_sagip_interest_balance].to_f}
      
      #============== para sa interest ========================
      sum = 0

      case @loan.num_installments
      when 15
        discount_factor = 14.2008332357486
        clip_factor = 0.007 
      when 25
        discount_factor = 22.8836620139337
        clip_factor = 0.007
      when 35
        discount_factor = 30.9876407825742
        clip_factor = 0.0105
      when 50
        discount_factor = 42.1419718090123
        clip_factor = 0.014
      else
        discount_factor = 58.3492770880972
        clip_factor = 0.021
      end

      total_discount_factor     = (@jef[:total_principal].to_f / discount_factor).round
      gt_total_discount_factor  = total_discount_factor * @loan.num_installments

      @jef[:total_principal_interest] = ((gt_total_discount_factor - @jef[:total_principal]).round).to_f
      #============== end para sa interest ========================
        a = Settings.loan_products.select{ |o| o[:loan_product_id] == "1c2fcdbd-d60b-402c-b04b-824bb90958d1" }.last
        total_insurance = 0
        a.deductions.each do |b|
          deduction_type  = b.meta["account_type"]
          if deduction_type == "INSURANCE"
            if b.meta["value"] != 0
              computed_value =  b.meta["value"].to_i * (@loan.num_installments.to_i + 1.to_i)
              new_computed_insurance = {
                  account_type: b.meta["account_type"],
                  account_subtype: b.meta["account_subtype"],
                  value: computed_value

              } 
              total_insurance = total_insurance + computed_value

            else
              d = 0
              total_amount = 0
              
                total_loan_amunt_with_insurance = @jef[:total_principal].to_f + @jef[:total_interest].to_f + total_insurance.to_f
                         
                first_clip = total_loan_amunt_with_insurance.to_f * clip_factor.to_f
                second_clip = ((total_loan_amunt_with_insurance.to_f + first_clip.to_f) * clip_factor.to_f).round(2)
            
                parts = second_clip.to_s.split(".")
                result = parts.count > 1 ? parts[1].to_s : 0
                #raise second_clip.inspect
                @jef[:total_service_fee] = (1.to_f - (result.to_f / 100 )).round(2)
              
              
              
              new_computed_insurance = {
                  account_type: b.meta["account_type"],
                  account_subtype: b.meta["account_subtype"],
                  value: second_clip

              } 
        
            end
           @jef[:insurance_details] << new_computed_insurance
          end
        end





      #============== insurance ===========================
      
      sum_total_laonable = 0
      @jef[:total_loanable_amount]  = ((@jef[:insurance_details].inject(0){|sum_total_laonable, x| sum_total_laonable + x[:value].to_f}) + @jef[:total_principal] + @jef[:total_interest] + @jef[:total_service_fee]).to_f
      

      #raise @jef.inspect
      @loan_data[:new_restructured] = @jef
      @loan.update(data: @loan_data)

    end
  
  end
end
