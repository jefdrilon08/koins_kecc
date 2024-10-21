module Dormants
  class Approve
    def initialize(config:)
      @config                 = config
      @data_store             = @config[:record]
      @data                   = @data_store.data.with_indifferent_access
      @accounting_entry_data  = @data_store.data.with_indifferent_access[:accounting_entry]
      @records                = @data[:record]	
      @header                 = @data[:header]
      @user                   = @config[:user]
      @total_payment          = @data[:total_payment]
      @date                   = ::Utils::GetCurrentDate.new(
                                  config: {
                                    branch: Branch.find(@data_store.meta["branch_id"])
                                  }
                                ).execute!
    end

    def execute!
      insert_payment!
      approved_entry!
      @accounting_entry_data[:reference_number] = @accounting_entry.reference_number
      @accounting_entry_data[:status]           = @accounting_entry.status
      @accounting_entry_data[:approved_by]      = @accounting_entry.approved_by
      @data_store.meta[:date_approved]          = @date

      @data_store.update!(status: "approved",data: {accounting_entry: @accounting_entry_data, record: @records , header: @header, total_payment: @total_payment})
      @data_store
    end

    def insert_payment!
      members_data = @records.each do |mem|
        amount = mem[:dormant_fee].to_f
        member_account = MemberAccount.find(mem[:subsidiary_id])
        member_balance = member_account.balance
    
        beginning_balance = member_balance
        ending_balance = beginning_balance - amount
    
        # Create AccountTransaction for each member
        account_transaction = AccountTransaction.new(
          subsidiary_id: mem[:subsidiary_id],
          subsidiary_type: "MemberAccount",
          amount: amount,
          transaction_type: "withdraw",
          transacted_at: @date,
          status: "approved",
          data: {
            is_withdraw_payment: true,
            beginning_balance: beginning_balance,
            ending_balance: ending_balance
          }
        )
    
        if account_transaction.save
          # Update the member account balance
          member_account.update!(balance: ending_balance)
    
          # Collect the transaction data for further use
          {
            subsidiary_id: mem[:subsidiary_id],
            amount: amount,
            beginning_balance: beginning_balance,
            ending_balance: ending_balance
          }
        else
          raise ActiveRecord::RecordInvalid, account_transaction
        end
      end
    
      members_data
    end
    

    def approved_entry!
      config  = {
        accounting_entry_data: @accounting_entry_data.with_indifferent_access,
        user: @user
      }
      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                          config: config
                        ).execute!
      # Post to books
      config  = {
        accounting_entry: accounting_entry,
        user: @user
      }
      @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                          config: config
                        ).execute!
      @accounting_entry
    end
  end
end
