module SavingsInsuranceTransferCollections
  class Approve
    def initialize(config:)
      @config                                 = config
      @user                                   = @config[:user]
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]

      @branch                 = @savings_insurance_transfer_collection.branch
      @data                   = @savings_insurance_transfer_collection.data.with_indifferent_access
      @accounting_entry_data  = @data[:accounting_entry]

      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
    end

    def execute!
      post_accounting_entry!
      withdraw_funds!
      deposit_funds!
      rehash_accounts!

      @savings_insurance_transfer_collection.update!(
        data: @data,
        approved_by: @user.full_name,
        date_approved: @date_approved
      )

      @savings_insurance_transfer_collection
    end

    private

    def rehash_accounts!
    end

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

    def withdraw_funds!
      values  = []

      @data[:records].each do |o|
        insurance_account_id          = o[:insurance_account_id]
        insurance_account_balance     = o[:insurance_account_balance].try(:to_f).try(:round, 2)
        amount                        = o[:amount].try(:to_f).try(:round, 2)
        insurance_account_new_balance = (insurance_account_balance + amount).to_f.round(2)
       
        # DEPOSIT TO SAVINGS
        subsidiary_id     = insurance_account_id
        subsidiary_type   = 'MemberAccount'
        transaction_type  = 'deposit'
        transacted_at     = @date_approved
        status            = 'approved'
        created_at        = Time.now.to_s(:db)
        updated_at        = Time.now.to_s(:db)

        data  = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: false,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          is_time_deposit: false,
          accounting_entry_reference_number: @accounting_entry.reference_number,
          beginning_balance: insurance_account_balance,
          ending_balance: insurance_account_new_balance,
          lock_in_period: nil
        }

        values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{data.to_json}')"
      end

      query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

      ActiveRecord::Base.connection.execute(query)
    end

    def deposit_funds!
      values  = []

      @data[:records].each do |o|
        savings_account_id          = o[:savings_account_id]
        savings_account_balance     = o[:savings_account_balance].try(:to_f).try(:round, 2)
        amount                      = o[:amount].try(:to_f).try(:round, 2)
        savings_account_new_balance = (savings_account_balance - amount).to_f.round(2)
       
        # DEPOSIT TO SAVINGS
        subsidiary_id     = savings_account_id
        subsidiary_type   = 'MemberAccount'
        transaction_type  = 'withdraw'
        transacted_at     = @date_approved
        status            = 'approved'
        created_at        = Time.now.to_s(:db)
        updated_at        = Time.now.to_s(:db)

        data  = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: false,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          is_time_deposit: false,
          accounting_entry_reference_number: @accounting_entry.reference_number,
          beginning_balance: savings_account_balance,
          ending_balance: savings_account_new_balance,
          lock_in_period: nil
        }

        values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{data.to_json}')"
      end

      query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

      ActiveRecord::Base.connection.execute(query)
    end
  end
end
