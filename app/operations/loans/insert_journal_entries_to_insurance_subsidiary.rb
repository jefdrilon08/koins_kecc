module Loans
  class InsertJournalEntriesToInsuranceSubsidiary
    def initialize(config:)
      @config             = config
      @insurance_subtype  = @config[:insurance_subtype]
      @accounting_code_id = @config[:accounting_code_id]
      @branch             = @config[:branch]
    end

    def execute!
      @data_result  = ::Loans::FetchJournalEntries.new(
                        config: {
                          accounting_code_id: @accounting_code_id,
                          branch: @branch
                        }
                      ).execute!

      values  = []

      @data_result[:records].each do |o|
        member_account  = MemberAccount.where(
                            account_subtype: @insurance_subtype,
                            account_type: "INSURANCE",
                            member_id: o[:member_id]
                          ).first

        if member_account.present?
          t = AccountTransaction.where(
                "DATE(transacted_at) = ? AND subsidiary_id = ?",
                o[:date_approved],
                member_account.id
              ).count

          if t == 0
            insurance_account_id      = member_account.id
            insurance_account_balance = member_account.balance
            transaction_type          = 'deposit'
            transacted_at             = o[:date_approved]
            created_at                = o[:date_approved]
            updated_at                = o[:date_approved]
            amount                    = o[:amount]
            status                    = 'approved'

            insurance_account_new_balance = (insurance_account_balance + amount).round(2)

            subsidiary_id     = insurance_account_id
            subsidiary_type   = 'MemberAccount'

            data  = {
              is_withdraw_payment: false,
              is_fund_transfer: false,
              is_interest: false,
              is_adjustment: false,
              is_for_exit_age: false,
              is_for_loan_payments: false,
              is_time_deposit: false,
              accounting_entry_reference_number: o[:reference_number],
              beginning_balance: insurance_account_balance,
              ending_balance: insurance_account_new_balance,
              lock_in_period: nil,
              misc: o
            }

            values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{data.to_json}')"
          end
        end
      end

      if values.any?
        query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

        ActiveRecord::Base.connection.execute(query)
      else
        false
      end
    end
  end
end
