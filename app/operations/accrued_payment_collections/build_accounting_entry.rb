module AccruedPaymentCollections
  class BuildAccountingEntry
    def initialize(accrued_billing:, current_user:)
      @user             = current_user
      @accrued_billing  = accrued_billing
      @book             = "CRB"
      @prepared_by      = @user.try(:full_name)
      @particular       = "To record payment for accrued interest"
      @branch           = Branch.find(@accrued_billing.branch_id) 
      @current_date     = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch
                            }
                          ).execute!
      end
      
    def execute!
      build_header_amount!
      @data         = @accrued_billing.data.with_indifferent_access

      @accounting_entry_data = @accrued_billing.data['accounting_entry']
      #raise @accounting_entry_data.inspect
      @accounting_entry_data[:debit_journal_entries]    = build_debit_journal_entries!
      @accounting_entry_data[:credit_journal_entries]   = build_credit_journal_entries!
      @accounting_entry_data[:journal_entries] = [] 
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }  
      end
      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }  
      end
 
      
      @data[:accounting_entry] = @accounting_entry_data
      @accrued_billing.data = @data
      @accrued_billing.save!
    end

    private
    def build_credit_journal_entries!
      #ab = @accrued_billing
      journal_entries = []
      hders = @accrued_billing.data['headers']
      hders.each do |hd|
        l_accounting_code = AccountingCode.find(hd['interest_receivable_accounting_code_id'])
        total_loan = @accrued_billing.data["headers"].select{ |o| o["name"] == hd["name"]}.last["interest_receivable_amount"]
          if total_loan > 0 and hd["name"] != "Withdraw Payment" 
            journal_entries << {
              accounting_code_id: l_accounting_code.id,
              code: l_accounting_code.code,
              name: l_accounting_code.name,
              amount: total_loan.to_f
            }
          end
      end
      journal_entries
    end

    def build_debit_journal_entries!
      journal_entries = []
      branch_accounting_code_id = Settings.branch_accounting_codes.select{ |o| o["branch_id"] == @branch.id }.first["cash_in_bank_accounting_code_id"]
      accounting_code = AccountingCode.find(branch_accounting_code_id)
      wp_accounting_code = AccountingCode.find("b7c23e58-e44e-46ae-a3ec-b5081d6eed32")
      total_interest_a = @accrued_billing.data["headers"].select{ |o| o["name"] != "Withdraw Payment" }
      total_interest = total_interest_a.sum{|ti| ti["interest_receivable_amount"].to_f}
      total_wp = @accrued_billing.data["headers"].select{ |o| o["name"] == "Withdraw Payment" }.last["interest_receivable_amount"]

      total_amount = total_interest - total_wp
      if total_wp > 0
        journal_entries << {
          accounting_code_id: wp_accounting_code.id,
          code: wp_accounting_code.code,
          name: wp_accounting_code.name,
          amount: total_wp.to_f
        }
      end

      if total_amount > 0
        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: total_amount.to_f
        }
      end 
 
      journal_entries
      #raise total_amount.inspect
      
    end
    
    def build_header_amount!
      ab = @accrued_billing
      hders = ab.data['headers']
      hders.each_with_index do |hd , i|
      
        j = ab.data['member_data'].sum{ |b| b["loan_data"] }
  

        u = j.select{ |y| y["name"] == hd["name"] }
        v = (u.sum{ |p| p["amount"] }).try(:to_f).try(:round, 2)
        hd['interest_receivable_amount'] = v
        ac = ab
        ac.data['headers'][i]['interest_receivable_amount'] = v
        ac.save!
      end
    
      mem_tot = ab.data['member_data']
      mem_tot.each do |mt|
        tt = 0
        tmcp = 0
        xx = ab.data['member_data'].select{|r| r['member_id'] == mt['member_id']}.last
        xx['loan_data'].each_with_index do |yy|
          if yy['name'] != "Withdraw Payment"
            tt += yy['amount'].round(2)
            tmcp +=  yy['amount'].round(2)
          elsif yy['name'] == "Withdraw Payment"
            tt -= yy['amount'].round(2)
          end
        end
        mt[:total_cp] = tt.round(2)
        mt[:total_payment] = tmcp.round(2)
      end

      cp_total = 0.0
      t_total = 0.0 
      cp = ab.data['headers'] 
      cp.each do |cps|
        if cps['name'] != "Withdraw Payment"
          cp_total += cps['interest_receivable_amount']
          t_total  += cps['interest_receivable_amount']
        elsif cps['name'] == "Withdraw Payment"
          cp_total -= cps['interest_receivable_amount']
        end
      end
      ab.data['total_cash_payment'] = cp_total.round(2)
      ab.data['total_payment'] = t_total.round(2)
    end

  end
end
