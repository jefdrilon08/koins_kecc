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
      @data[:records].each do |r|
        ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(r[:insurance_account_id])).execute!
        ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(r[:savings_account_id])).execute!
        
      end
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

    def deposit_funds!
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
        created_at        = Time.now.to_s
        updated_at        = Time.now.to_s

        if @savings_insurance_transfer_collection.clip
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
            data: 
              {
                id: nil,
                principal: o[:clip_data][:principal].try(:to_f).try(:round, 2),
                interest: nil,
                first_date_of_payment: nil,
                maturity_date: o[:clip_data][:maturity_date],
                original_maturity_date: nil,
                accounting_entry_id: nil,
                journal_entry_id: nil,
                amount: amount,
                loan_product_id: o[:clip_data][:loan_product_id],
                loan_product_name: o[:clip_data][:loan_product_name],
                member_id: o[:member][:id],
                date_approved: o[:clip_data][:effective_date],
                date_released: o[:clip_data][:effective_date],
                reference_number: nil,
                book: nil,
                member_account_id: subsidiary_id,
                term: o[:clip_data][:term],
                num_installments: o[:clip_data][:num_installments],
                account_transaction_id: nil,
                status: nil,
                beneficiary: o[:clip_data][:beneficiary]
              }
          }
        else
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
        end

        values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{data.to_json}')"

        # TODO: Make this to DB trigger function
        MemberAccount.find(insurance_account_id).update!(balance: insurance_account_new_balance)
      end

      query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

      ActiveRecord::Base.connection.execute(query)
    end

    def withdraw_funds!
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
          accounting_entry_reference_number: @accounting_entry.reference_number,
          beginning_balance: savings_account_balance,
          ending_balance: savings_account_new_balance,
          lock_in_period: nil
        }

        values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{data.to_json}')"

        # TODO: Make this to DB trigger function
        MemberAccount.find(savings_account_id).update!(balance: savings_account_new_balance)
      end

      query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

      ActiveRecord::Base.connection.execute(query)
    end
  end
end
