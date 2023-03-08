module AdditionalShare
  class Approve
    def initialize(config:)    
      @config                 = config       
      @data_store             = @config[:record]
      @data                   = @data_store.data.with_indifferent_access
      @accounting_entry_data  = @data_store.data.with_indifferent_access[:accounting_entry]
      @records                = @data[:record]       
      @header                 = @data[:header]
      @user                   = @config[:user]
      @date                   = ::Utils::GetCurrentDate.new(
                                   config: {
                                      branch: Branch.find(@data_store.meta["branch_id"])
                                      }
                                    ).execute!  

      
    end 

    def execute!
      insert_share_cap!
      withdraw_transaction!
      approved_entry!
      @accounting_entry_data[:reference_number] = @accounting_entry.reference_number
      @accounting_entry_data[:status]           = @accounting_entry.status
      @accounting_entry_data[:approved_by]      = @accounting_entry.approved_by
      @data_store.meta[:date_approved] = @date
      @data_store.update!(status: "approved",data: {accounting_entry: @accounting_entry_data, record: @records , header: @header})
      @data_store
    end
    
    def withdraw_transaction!
      @records.each do |r|
        r[:records].each do |o|
          if o[:amount] > 0 
            account_transaction = AccountTransaction.new(
              amount: o[:amount],
              subsidiary_id: o[:member_account_id],
              subsidiary_type: "MemberAccount",
              transaction_type: "withdraw",
              transacted_at: @date,
              status: "approved",
              data: {
                is_withdraw_payment: false,
                beginning_balance: 0.0,
                ending_balance: 0.0
              }
              )
              account_transaction.save!
              ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(o[:member_account_id]), account_transactions: nil).execute!
          end
        end
      end
    end

    def insert_share_cap!
      @records.each do |o|
        if o[:total_add_capital] > 0
          account_transaction = AccountTransaction.new(
            amount: o[:total_add_capital],
            subsidiary_id: o[:member_account_id],
            subsidiary_type: "MemberAccount",
            transaction_type: "deposit",
            transacted_at: @date,
            status: "approved",
            data: {
              is_withdraw_payment: false,
              beginning_balance: 0.0,
              ending_balance: 0.0
            }
            )
            account_transaction.save!
            ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(o[:member_account_id]), account_transactions: nil).execute!
        end
      end
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
