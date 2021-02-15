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
      
        last_regular_payment = AccountTransaction.where("subsidiary_id =? and transacted_at < ? and status = ? and amount > 0", loan_data[:id], @loan.date_prepared,"approved" ).order(:transacted_at).last
        
        if last_regular_payment == nil
          amort_details =  AmortizationScheduleEntry.where(loan_id: loan_data[:id]).order(:due_date).first
          a = amort_details.due_date
          last_regular_payment_transacted_at = amort_details.due_date
          
        else
          last_regular_payment_data =  last_regular_payment.data.with_indifferent_access
          a = last_regular_payment_data[:amort_entries].sort_by{ |o| o["due_date"]}.last[:due_date]
          last_regular_payment_transacted_at = last_regular_payment.transacted_at.to_date

        end


        ksagip_payment = AccountTransaction.where("subsidiary_id =?", loan_data[:id]).order(:transacted_at).last
        
        receivable_accounting_code = Settings.loan_products.select{ |o| o[:loan_product_id] == reg_loan.loan_product.id }.last.receivable_accounting_code_id
        interest_receivable_accounting_code = Settings.loan_products.select{ |o| o[:loan_product_id] == reg_loan.loan_product.id }.last.interest_receivable_accounting_code_id
         
            if @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] ==  interest_receivable_accounting_code}.present?
              old_loan_interest = @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] ==  interest_receivable_accounting_code}.last["amount"]
            else
              old_loan_interest = 0.0
            end

        #last_regular_payment_data =  last_regular_payment.data.with_indifferent_access
        #a = last_regular_payment_data[:amort_entries].sort_by{ |o| o["due_date"]}.last[:due_date]

                 
          if last_regular_payment_transacted_at.to_date <= a.to_date 

            if last_regular_payment_transacted_at.to_date > ksagip_payment.transacted_at.to_date
             #pag walang past due
             
             new_restructure = { id: reg_loan.id,
                              pn_number: reg_loan.pn_number,
                              principal_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              k_sagip_interest_balance: total_interest,
                              interest_balance: 0.0,
                              total_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              transaction_type: "current",
                              sagip_transaction_date: @loan.date_prepared,
                              loan_product: {
                                id: reg_loan.loan_product.id,
                                name: reg_loan.loan_product.name,
                                receivable_accounting_code_id: receivable_accounting_code,
                                interest_receivable_accounting_code_id: interest_receivable_accounting_code,
                                old_receivable_amount: @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] ==  receivable_accounting_code}.last["amount"],
                                old_interest_receivable_amount: old_loan_interest
                      
                              }

                            }
              
            else
        
              total_interest = 0
              ksagip_payment.data.with_indifferent_access[:amort_entries].select{ |p| p[:due_date].to_date <= @loan.date_prepared.to_date}.each do |kpayment|
                total_interest = total_interest.to_f + kpayment[:interest_paid].to_f
              end
            
              new_restructure = { id: reg_loan.id,
                              pn_number: reg_loan.pn_number,
                              principal_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              k_sagip_interest_balance: total_interest,
                              interest_balance: ksagip_payment.data.with_indifferent_access[:total_interest_paid],
                              total_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid].to_f + total_interest.to_f,
                              transaction_type: "pastdue",
                              sagip_transaction_date: @loan.date_prepared,
                              loan_product: {
                                id: reg_loan.loan_product.id,
                                name: reg_loan.loan_product.name,
                                receivable_accounting_code_id: receivable_accounting_code,
                                interest_receivable_accounting_code_id: interest_receivable_accounting_code,
                                old_receivable_amount: @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] ==  receivable_accounting_code}.last["amount"],
                                old_interest_receivable_amount: old_loan_interest
                              }

                            }
            end
          else
            
            if reg_loan.maturity_date.to_date >  ksagip_payment.transacted_at.to_date
              trans_type = "pastdue"
            else
              trans_type = "overdue"
            
            end
            total_interest = 0
            ksagip_payment.data.with_indifferent_access[:amort_entries].select{ |p| p[:due_date].to_date <= @loan.date_prepared.to_date}.each do |kpayment|
              total_interest = total_interest.to_f + kpayment[:interest_paid].to_f
            end
            
            
                        
            new_restructure = { id: reg_loan.id,
                              pn_number: reg_loan.pn_number,
                              principal_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid],
                              k_sagip_interest_balance: total_interest,
                              interest_balance: ksagip_payment.data.with_indifferent_access[:total_interest_paid],
                              total_balance: ksagip_payment.data.with_indifferent_access[:total_principal_paid].to_f + total_interest.to_f,
                              transaction_type: trans_type,
                              sagip_transaction_date: @loan.date_prepared,
                              loan_product: {
                                id: reg_loan.loan_product.id,
                                name: reg_loan.loan_product.name,
                                receivable_accounting_code_id: receivable_accounting_code,
                                interest_receivable_accounting_code_id: interest_receivable_accounting_code,
                                old_receivable_amount: @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] ==  receivable_accounting_code}.last["amount"],
                                old_interest_receivable_amount: old_loan_interest
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
                  accounting_entry: b["accounting_code_id"],
                  value: computed_value,
                  old_value: @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] == b["accounting_code_id"]}.last["amount"]

              } 
              total_insurance = total_insurance + computed_value

            else
              d = 0
              total_amount = 0
              
                total_loan_amunt_with_insurance = @jef[:total_principal].to_f + @jef[:total_interest].to_f + total_insurance.to_f
                         
                first_clip = total_loan_amunt_with_insurance.to_f * clip_factor.to_f
                second_clip_details = (total_loan_amunt_with_insurance.to_f + first_clip.to_f)
                second_clip =  (second_clip_details.round * clip_factor.to_f).round(2)
                
                parts = second_clip.to_s.split(".")
                
                #result = parts.count > 1 ? (((parts[0].to_i + 1.to_i) - second_clip.to_f).round(2) ) : second_clip
                result1 =  ((total_loan_amunt_with_insurance + second_clip).round - (total_loan_amunt_with_insurance + second_clip).to_f).round(2)
                if result1 < 0
                  
                  #result = ((1.to_f - result1.to_f.abs) * -1.to_i )
                  result = 1.to_f - result1.to_f.abs
                else
                
                  result = result1.to_f.abs
                end

              
                  
              
              
            
                

                @jef[:total_service_fee] = result
                if @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] == "9f4b1331-cd5a-4edb-9920-a5029759885d"}.count == 0
                  @jef[:total_old_service_fee] = 0
                else
                  @jef[:total_old_service_fee] = @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] == "9f4b1331-cd5a-4edb-9920-a5029759885d"}.last["amount"]
                end
              
              
              new_computed_insurance = {
                  account_type: b.meta["account_type"],
                  account_subtype: b.meta["account_subtype"],
                  accounting_entry: b["accounting_code_id"],
                  value: second_clip,
                  old_value: @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] == b["accounting_code_id"]}.last["amount"]

              } 
        
            end
           @jef[:insurance_details] << new_computed_insurance
          end
        end





      #============== insurance ===========================
      
      sum_total_laonable = 0
      @jef[:total_loanable_amount]  = ((@jef[:insurance_details].inject(0){|sum_total_laonable, x| sum_total_laonable + x[:value].to_f}) + @jef[:total_principal] + @jef[:total_interest] + @jef[:total_service_fee].to_f.abs).to_f.round
      

      #raise @jef.inspect
      #@loan_data[:new_restructured] = @jef
      #@loan.update(data: @loan_data)
       @jef
    end
  
  end
end
