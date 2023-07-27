class ProcessReceivePaymentApi < ApplicationJob
  queue_as :default

  def perform(payments)
    @payments = []
    @transaction = []
    config = {}
    @rf_counter = 0
    @lif_counter = 0
    @lif_account_subtype = "Life Insurance Fund"
    @rf_account_subtype = "Retirement Fund"

    payments.each do |m|
      @payment_data = {}
      @payment_data[:identification_number]     =m["identification_number"]
      @payment_data[:amount]                    =m["amount"]
      @payment_data[:account_subtype]           =m["account_subtype"]
      @payment_data[:transacted_at]             =m["transacted_at"]
      @payment_data[:status]                    =m["status"]

      @payments << @payment_data 
           
      config = @payments.map{ |o|
        {
          identification_number: o[:identification_number],    
          amount: o[:amount],                   
          account_subtype: o[:account_subtype],          
          transacted_at: o[:transacted_at],            
          status: o[:status]                   
        }
      }
    end

    # raise config.inspect 
    config.each do |a|
      @member = Member.where(identification_number: a[:identification_number])
      @member.each do |b|
        if a[:account_subtype] == 'Life Insurance Fund'
          @subsidiary_id = MemberAccount.where("member_accounts.member_id = ? AND member_accounts.account_subtype IN (?)", b[:id], @lif_account_subtype)
          @subsidiary_id.each do |c|
            payment_data = {
              subsidiary_id: c[:id],
              subsidiary_type: "MemberAccount",
              amount: a[:amount],
              transaction_type: "deposit",
              transacted_at: a[:transacted_at],
              status: a[:status],
              data: {
                is_withdraw_payment: false,
                is_fund_transfer: false,
                is_interest: false,
                is_adjustment: false,
                is_for_exit_age: false,
                is_for_loan_payments: false,
                accounting_entry_reference_number: nil,
                beginning_balance: 0.0,
                ending_balance: 0.0
              },
              created_at: a[:created_at],
              pdated_at: a[:updated_at]  
            }
            
            cmd = Kmba::SavePayment.new(
              payment_data: payment_data
            ).execute!
            @lif_counter += 1
          end  
        elsif a[:account_subtype] == 'Retirement Fund'
          @subsidiary_id = MemberAccount.where("member_accounts.member_id = ? AND member_accounts.account_subtype IN (?)", b[:id], @rf_account_subtype)
          @subsidiary_id.each do |c|
            payment_data = {
              subsidiary_id: c[:id],
              subsidiary_type: "MemberAccount",
              amount: a[:amount],
              transaction_type: "deposit",
              transacted_at: a[:transacted_at],
              status: a[:status],
              data: {
                is_withdraw_payment: false,
                is_fund_transfer: false,
                is_interest: false,
                is_adjustment: false,
                is_for_exit_age: false,
                is_for_loan_payments: false,
                accounting_entry_reference_number: nil,
                beginning_balance: 0.0,
                ending_balance: 0.0
              },
              created_at: a[:created_at],
              pdated_at: a[:updated_at]  
            }

            cmd = Kmba::SavePayment.new(
              payment_data: payment_data
            ).execute!
            @rf_counter += 1
          end 
        end  
      end    
    end

    if @rf_counter > 0 && @lif_counter > 0
      puts "status: 200, code: KMBA-002, RetirementFund: #{@rf_counter} ,LifeInsuranceFund: #{@lif_counter}"
    elsif @lif_counter > 0
      puts "status: 200, code: KMBA-002, LifeInsuranceFund: #{@lif_counter}"
    elsif @rf_counter > 0
      puts "status: 200, code: KMBA-002, RetirementFund: #{@rf_counter}"
    end  
  end
end
