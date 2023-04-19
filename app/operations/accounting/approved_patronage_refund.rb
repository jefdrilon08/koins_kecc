module Accounting
  class ApprovedPatronageRefund
    attr_accessor :result

    def initialize(config:)
      @config                   = config
      @data_store               = @config[:data_store]
      @user                     = @config[:user]
      @data                     = @data_store.data.with_indifferent_access
      @branch                   = Branch.find(@data[:branch][:id])
      @accounting_entry_data    = @data[:accounting_entry]
      @savings_account_type     = Settings.savings_account_type
      @savings_account_subtype  = Settings.savings_account_subtype
      @cbu_account_type         = Settings.cbu_account_type
      @cbu_account_subtype      = Settings.cbu_account_subtype

      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
    end

    def execute!
      post_accounting_entry!
      insert_funds!
      rehash_savings!

      # Rehash accounts
      # ::MemberAccounts::BulkRehash.new(
      #   config: {
      #     branch: @branch
      #   }
      # ).execute!

      @data_store.update!(data: @data)

      @data_store
    end

    private

    def post_accounting_entry!
      # Create new accounting entry
      config  = {
        accounting_entry_data: @accounting_entry_data,
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

      @accounting_entry_data[:status]           = 'approved'
      @accounting_entry_data[:approved_by]      = @user.to_s
      @accounting_entry_data[:reference_number] = @accounting_entry.reference_number
      @accounting_entry_data[:id]               = @accounting_entry.id

      @data[:accounting_entry]  = @accounting_entry_data
      @data[:status]            = "approved"

      @accounting_entry
    end

    def insert_funds!
      values  = []
      
      @data[:records].each do |o|
        member_id                   = o[:id]
        savings_account_id          = MemberAccount.where(member_id: member_id, account_type: "SAVINGS",account_subtype: "Maintaining Balance Savings").ids.shift
        savings_account_balance     = MemberAccount.find(savings_account_id).balance.round(2)
        savings_distribute          = o[:savings_distribute].to_f.round(2)
        savings_account_new_balance = (savings_account_balance + savings_distribute).round(2)
       
        # DEPOSIT TO SAVINGS
        subsidiary_id     = savings_account_id
        subsidiary_type   = 'MemberAccount'
        amount            = savings_distribute
        transaction_type  = 'deposit'
        transacted_at     = @date_approved
        status            = 'approved'
        created_at        = Time.now.to_s
        updated_at        = Time.now.to_s

        data  = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: true,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          is_time_deposit: false,
          is_patronage_refund: true,
          accounting_entry_reference_number: @accounting_entry.reference_number,
          beginning_balance: savings_account_balance,
          ending_balance: savings_account_new_balance,
          lock_in_period: nil
        }

        values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{data.to_json}')"

        cbu_account_id              = MemberAccount.where(member_id: member_id, account_type: "EQUITY",account_subtype: "CBU").ids.shift
        cbu_account_balance         = MemberAccount.find(cbu_account_id).balance.round(2)
        cbu_distribute              = o[:cbu_distribute].to_f.round(2)
        cbu_account_new_balance     = (cbu_account_balance + cbu_distribute).round(2)

        # DEPOSIT TO EQUITY
        subsidiary_id     = cbu_account_id
        subsidiary_type   = 'MemberAccount'
        amount            = cbu_distribute
        transaction_type  = 'deposit'
        transacted_at     = @date_approved
        status            = 'approved'
        created_at        = Time.now.to_s
        updated_at        = Time.now.to_s

        data  = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: false,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          is_time_deposit: false,
          is_patronage_refund: true,
          accounting_entry_reference_number: nil,
          beginning_balance: cbu_account_balance,
          ending_balance: cbu_account_new_balance,
          lock_in_period: nil
        }

        values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{data.to_json}')"
      end

      query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

      ActiveRecord::Base.connection.execute(query)
    end
    def rehash_savings!
      @data[:records].each do |o|
        member_id                   = o[:id]
        personal_savings_account    = MemberAccount.where(member_id: member_id, account_type: "SAVINGS",account_subtype: "Maintaining Balance Savings").ids.shift
        cbu_account                 = MemberAccount.where(member_id: member_id, account_type: "EQUITY",account_subtype: "CBU").ids.shift
        ::MemberAccounts::Rehash.new(
          member_account: MemberAccount.find(personal_savings_account), account_transactions: nil).execute!

        ::MemberAccounts::Rehash.new(
          member_account: MemberAccount.find(cbu_account), account_transactions: nil).execute!
      end
    end
  end
end
