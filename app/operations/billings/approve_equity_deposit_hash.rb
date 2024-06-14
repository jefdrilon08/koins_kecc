module Billings
  class ApproveEquityDepositHash
    def initialize(config:)
      @config     = config
      @date_paid  = @config[:date_paid]
      @deposit    = @config[:deposit]
      @user       = @config[:user]
      @particular = @config[:particular]
      @amount     = @deposit[:amount].try(:to_f).round(2)
      #raise @amount.inspect
      @transaction_type = "deposit"

      @member_account = MemberAccount.find(@deposit[:member_account_id])
      @member =Member.find(@member_account.member_id)
      @account_transaction  = AccountTransaction.new(
                                subsidiary_id: @member_account.id,
                                subsidiary_type: "MemberAccount",
                                amount: @amount,
                                transaction_type: @transaction_type,
                                transacted_at: @date_paid,
                                status: "approved"
                              )

      @data = {
        is_withdraw_payment: false,
      #  is_fund_transfer: false,
        is_interest: false,
        is_adjustment: false,
        is_for_exit_age: false,
        is_for_loan_payments: false,
        accounting_entry_reference_number: nil,
        beginning_balance: 0.00,
        ending_balance: 0.00
      }

      
    end

    def execute!
      # Compute beginning and ending balance
      @data[:beginning_balance] = @member_account.balance.round(2)
      @data[:ending_balance]    = (@data[:beginning_balance] + @amount).round(2)

      # Update account balance
      new_balance = (@member_account.balance + @amount).round(2)
      @member_account.update(
        balance: new_balance
      )

    
      @account_transaction.data = @data
      @account_transaction.save!
      @member_new_balance = @member_account.balance.to_f


      MemberAccount.joins(:member).where("members.data->'subscription'->>'is_subscribed' = ? AND member_accounts.account_subtype = ? AND member_accounts.balance >= ?", "true", "CBU", 100.00).count
      if @member.data.with_indifferent_access[:subscription].present? and @member.data['subscription']['is_subscribed'] == true
        
        if @member_new_balance.to_f >= 100.to_f
        
          withdraw_cbu!
          move_cbu!
        end
      end


    end
    

    def withdraw_cbu!
      @transaction_type = "withdraw"
      @divisible_amount = @member_new_balance / 100.to_i
      #raise @divisible_amount.to_i.inspect
      if @divisible_amount > 0
        @withdraw_amount = @divisible_amount.to_i * 100
      end
      @account_transaction_withdraw  = AccountTransaction.new(
                                subsidiary_id: @member_account.id,
                                subsidiary_type: "MemberAccount",
                                amount: @withdraw_amount,
                                transaction_type: @transaction_type,
                                transacted_at: @date_paid,
                                status: "approved"
                              )

      @data = {
        is_withdraw_payment: false,
        is_fund_transfer: false,
        is_interest: false,
        is_adjustment: false,
        is_for_exit_age: false,
        is_for_loan_payments: false,
        accounting_entry_reference_number: nil,
        beginning_balance: 0.00,
        ending_balance: 0.00
      }
      
      # Compute beginning and ending balance
      @data[:beginning_balance] = @member_account.balance.round(2)
      @data[:ending_balance]    = (@data[:beginning_balance] - @withdraw_amount).round(2)

      # Update account balance
      new_balance = (@member_account.balance - @withdraw_amount).round(2)
      @member_account.update(
        balance: new_balance
      )
      
      @account_transaction_withdraw.data = @data
      @account_transaction_withdraw.save!
      #raise "jef".inspect
    end
    
    def move_cbu!
      
      member_account = MemberAccount.find(@deposit['member_account_id'])
      
      #sharecapital account
      sc_member_account = MemberAccount.where(member_id: member_account.member_id, account_subtype: "Share Capital" ).last


      particular = "To record transfer of cbu for payment of additional share capital *name, amount)"
      amount = @withdraw_amount
      
      config = {
        date_paid: @date_paid,
        member_account_id: sc_member_account.id,
        user: @user,
        particular: particular,
        amount: amount

      }
      
      ::Billings::MoveEquityDepositHash.new(config: config).execute!
    

    end





  end
end
