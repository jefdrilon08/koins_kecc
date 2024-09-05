module InvoluntaryPayment
  class Approve
    def initialize(config:)
      @config                 = config
      @data_store             = @config[:record]
      @data                   = @data_store.data.with_indifferent_access
      @accounting_entry_data  = @data_store.data.with_indifferent_access[:accounting_entry]
      @records                = @data[:record]	
      @header                 = @data[:header]
      @user                   = @config[:user]
      @total_cash_payment     = @data[:total_cash_payment]
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
      @data_store.update!(status: "approved", data: {
        accounting_entry: @accounting_entry_data,
        record: @records,
        header: @header,
        total_cash_payment: @total_cash_payment,
        total_payment: @total_payment
      })
      @data_store
    end

    def insert_payment!
      enabled_member = @records.select { |y| y[:enabled] == true }
      enabled_member.each do |em|
        em[:loan_data].each do |ld|
          next unless ld[:enabled] == true

          if ld[:name] != "Withdraw Payment"
            # Ensure that loan_id is present
            if ld[:loan_id].nil? || ld[:loan_id].empty?
              Rails.logger.error("Missing loan_id for loan: #{ld.inspect}")
              next # Skip this loan if loan_id is missing
            end

            @amort = []
            ld[:loan_amort].each do |amort|
              if amort[:total_amount] > 0
                @amort << {
                  id: amort[:amort_id],
                  due_date: amort[:due_date],
                  principal_paid: amort[:principal_amount].to_f.round(2),
                  interest_paid: amort[:interest_amount].to_f.round(2)
                }
              end
            end

            # Create the account transaction for the loan payment
            account_transaction = AccountTransaction.new(
              amount: ld[:amount],
              subsidiary_id: ld[:loan_id], # This is the loan_id extracted from the Create process
              subsidiary_type: "Loan",
              transaction_type: "loan_payment",
              transacted_at: @date,
              status: "approved",
              data: {
                amort_entries: @amort,
                total_interest_paid: ld[:interest_amount].to_f.round(2),
                total_principal_paid: ld[:principal_amount].to_f.round(2),
                amount_due: ld[:amount],
                particular: @accounting_entry_data[:particular],
                approved_by: @user.full_name
              }
            )
            account_transaction.save!

            # Fix the amortization schedule
            ::Loans::FixAmort.new(loan: Loan.find(ld[:loan_id])).execute!
          elsif ld[:name] == "Withdraw Payment"
            account_transaction = AccountTransaction.new(
              amount: ld[:amount],
              subsidiary_id: ld[:savings_account_id],
              subsidiary_type: "MemberAccount",
              transaction_type: "withdraw",
              transacted_at: @date,
              status: "approved",
              data: {
                is_withdraw_payment: true,
                beginning_balance: 0.0,
                ending_balance: 0.0
              }
            )
            account_transaction.save!
            ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(ld[:savings_account_id]), account_transactions: nil).execute!
          end
        end
      end
    end

    def approved_entry!
      config = {
        accounting_entry_data: @accounting_entry_data.with_indifferent_access,
        user: @user
      }
      accounting_entry = ::Accounting::AccountingEntries::Save.new(
        config: config
      ).execute!

      # Post to books
      config = {
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
