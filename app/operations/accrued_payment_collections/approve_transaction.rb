module AccruedPaymentCollections
  class ApproveTransaction
    def initialize(config:)
      @config             = config
      @data_store_id      = @config[:data_store_id]
      @date_approved      = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch }).execute!
    end

    def execute!
      billing = AccruedBilling.find(@data_store_id)
      #raise @date_approved.inspect
      
      billing.data['member_data'].each do |md|
        md['loan_data'].each do |ld|
          
          if ld['enabled'] == true && ld['amount'] > 0.0 && ld['loan_id'].present?
            a = Loan.find(ld['loan_id'])
            a_data = a.data.with_indifferent_access
            data_bal = a_data[:accrued_interest][:total_accrued_interest_balance] + ld['amount']
            a_data[:accrued_interest][:total_accrued_interest_balance] = data_bal
            a.update(data: a_data)
            
            b = Loan.find(ld['loan_id'])
            tot_acc_int = b.data['accrued_interest']['total_accrued_interest']
            acc_paid = b.data['accrued_interest']['total_accrued_interest_balance']
            b_data = b.data.with_indifferent_access
            if tot_acc_int == acc_paid
              b_data[:accrued_interest][:status] = 'paid'
            else
              b_data[:accrued_interest][:status] = 'active'
            end
            b.update(data: b_data)

            c = AccountTransaction.new(
            subsidiary_id: ld['loan_id'] ,
            subsidiary_type: 'Loan' ,
            amount: ld['amount'] ,
            transaction_type: 'accrued_interest_payment' ,
            transacted_at:  @date_approved ,
            status: 'approved' ,
            data: {
              beginning_balance: "0.0" ,
              ending_balance: 0.0 ,
              remaining_balance: "0.0" ,
              approved_by: "SYSTEM"
            }
            )
            c.save!
          end
          
          if ld['enabled'] == true && ld['amount'] > 0.0 && ld['mem_acc'].present?
            at = AccountTransaction.new(
              subsidiary_id: ld['mem_acc'] , 
              subsidiary_type: 'MemberAccount' , 
              amount: ld['amount'] , 
              transaction_type: 'withdraw' , 
              transacted_at: @date_approved , 
              status: 'approved' , 
              data: {
                beginning_balance: "0.00" , 
                ending_balance: "0.0" , 
                remaining_balance: "0.0" ,
                is_withdraw_patment: true ,
                approved_by: "SYSTEM"
                }
              )
            at.save!
            ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(ld['mem_acc']), account_transactions: nil ).execute!
          end
            
        end
      end
      billing.update(status: 'approved' ,   date_approved: @date_approved)
    end


  end
end
