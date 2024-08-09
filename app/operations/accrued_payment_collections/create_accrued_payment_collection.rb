module AccruedPaymentCollections
  class CreateAccruedPaymentCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      
      @user             = @config[:user]
      @branch_id        = @config[:branch_id]
      @branch           = @config[:branch]
      @center           = @config[:center_id]
      @member           = @config[:member_id]
      @current_date = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!



      @accrued_billing  = AccruedBilling.new(
                                          collection_date: @current_date,
                                          branch_id: @branch_id,
                                          center_id: @center,
                                          member_id: @member,
                                          status: 'pending',
                                          data: {
                                            total_cash_payment: 0.0,
                                            total_payment: 0.0,
                                            member_data:[],
                                            headers:[],
                                            records:[],
                                            accounting_entry: {},
                                          }
                                        )

    end

    def execute!
      process_accrued_data!
      process_accounting_entry!
      acc_status!
      @accrued_billing.save!
      @accrued_billing
    end

    def process_accrued_data!
      @header = []
      @record = []
      dta = Loan.joins(:member).where("members.center_id = ? and loans.data ->> 'accrued_interest' IS NOT NULL" , @center)   
      dta.pluck(:loan_product_id).uniq.each do |dt|
        @header << LoanProduct.find(dt)
      end
      @header.uniq.each do |hd|
        st = Settings.loan_products.select{|l| l[:loan_product_id] == hd.id}.first
        @accrued_billing.data['headers'] << {
          name: hd.name,
          id:   hd.id,
          interest_receivable_accounting_code_id: st[:interest_receivable_accounting_code_id],
          interest_receivable_amount: 0.0,
          is_active: ''
      }
      end
      @accrued_billing.data['headers'] << {
          name: "Withdraw Payment",
          id:   "",
          interest_receivable_accounting_code_id: "b7c23e58-e44e-46ae-a3ec-b5081d6eed32",
          interest_receivable_amount: 0.0
      }

    
      dta.order(:last_name).pluck(:member_id).uniq.each do |rec|
          @accrued_billing.data['member_data'] << {  
            member_id: rec,
            name:      Member.find(rec).full_name,
            is_active: '',
            total_cp: 0.0,
            total_payment: 0.0,
            loan_data: []
          }
      end

      @accrued_billing.data['member_data'].each do |ld|
         @header.each do |hd|
          l = Loan.where("member_id = ? and loan_product_id = ? and data ->> 'accrued_interest' IS NOT NULL" , ld[:member_id] , hd.id ).ids.last 
          if l.nil?
          else 
            x = Loan.find(l)
            amt = x.data['accrued_interest']['total_accrued_interest'] - x.data['accrued_interest']['total_accrued_interest_balance']
          end
          if x.present? and x.data['accrued_interest']['status'] != 'remove' and x.data['accrued_interest']['status'] != 'paid'

            ld[:loan_data] << { 
              name:     hd.name,
              enabled:  true,
              loan_id:  x.id,
              loan_product_id: x.loan_product_id,
              amount:   amt.to_f.round(2)

            }
          else
            ld[:loan_data] << { 
              name:     hd.name,
              enabled:  false,
              loan_id:  '',
              loan_product_id: '',
              amount:   0.0                   
            }
          end
        end
          mem_acc = MemberAccount.where(member_id: ld[:member_id] , account_type: 'SAVINGS' , account_subtype: 'K-IMPOK').last.id
          ld[:loan_data] << { 
              name:     "Withdraw Payment",
              enabled:  true,
              mem_acc:  mem_acc,
              amount:   0.0

            }

      end
   end
    
    def acc_status!
      ab  = @accrued_billing
      mem_tot = ab.data['member_data']
      mem_tot.each do |mt|
        tt = 0
        mem_data = ab.data['member_data'].select{|r| r['member_id'] == mt['member_id']}.last
        mem_data['loan_data'].each do |md|
          tt += md['amount']
        end
        if tt == 0.0
          mt[:is_active] = false
        else
          mt[:is_active] = true
        end
      end
        
      hders = ab.data['headers']
      hders.each_with_index do |hd , i|
        j = ab.data['member_data'].sum{ |b| b["loan_data"] }
        if j != 0
          u = j.select{ |y| y["name"] == hd["name"] }
          v = (u.sum{ |p| p["amount"] }).to_f.round(2)
          if v == 0.0 and hd["name"] != "Withdraw Payment"
            hd[:is_active] = false
          else 
            hd[:is_active] = true
          end
        end
      end
    end

    def process_accounting_entry!
      particular = 'To record accrued payment'
      acc_b = @accrued_billing
      @accounting_entry_data= {
          book: "CRB",
          reference_number: "",
          date_prepared: @current_date.strftime("%B %d, %Y"),
          company_name: Settings.company_name,
          company_address: Settings.company_address,
          branch: @branch.to_s.upcase,
          prepared_by: @user.to_s,
          particular: particular,
          debit_journal_entries: [],
          credit_journal_entries: [],
          journal_entries: [],
          branch_id: @branch.id,
          branch_name: @branch.name,
          status: "display",
          data: {
            or_number: "",
            ar_number: "",
            si_number: "",
            check_number: "",
            check_voucher_number: "",
            date_of_check: "",
            sub_reference_number: "",
            payee: ""
          }
        }
        acc_b.data['accounting_entry'] = @accounting_entry_data
        acc_b.save!
    end

  end
end
