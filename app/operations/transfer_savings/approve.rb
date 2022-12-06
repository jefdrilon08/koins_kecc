module TransferSavings
  class Approve

    def initialize(config:)
      @config = config
      @transfer_savings_record = TransferSavingsRecord.find(@config[:transfer_savings_record])
      @user = User.find(@config[:user])
      @member_records = @transfer_savings_record.data.with_indifferent_access[:member_records]
      @accounting_entry = @transfer_savings_record.data.with_indifferent_access[:accounting_entry]
      @current_date = ::Utils::GetCurrentDate.new(
              config: {
                branch: Branch.find(@transfer_savings_record.branch_id)
                }
              ).execute! 

    end

    def execute!
      approve_accounting_entry!
      @member_records.each do |data|
        
        #create account_transaction withdraw for PSA
            acc_trans_psa = AccountTransaction.new(
              subsidiary_id: data[:psa_account_id],
              subsidiary_type: "MemberAccount",
              amount: data[:psa_balance].to_f,
              transaction_type: "withdraw",
              transacted_at: @current_date,
              status: "approved",
              data: {
                is_withdraw_payment: false,
                is_fund_transfer: false,
                is_interest: false,
                is_adjustment: false,
                is_for_loan_payments: false,
                accounting_entry_reference_number: @accounting_entry.reference_number,
                beginning_balance: data[:psa_balance].to_f,
                ending_balance: 0.0
              }
              )
            acc_trans_psa.save!
            MemberAccount.find(data[:psa_account_id]).update(balance: 0.0)
            #create account_transaction deposit for MBS
            acc_trans_mbs =  AccountTransaction.new(
              subsidiary_id: data[:mbs_account_id],
              subsidiary_type: "MemberAccount",
              amount: data[:psa_balance].to_f,
              transaction_type: "deposit",
              transacted_at: @current_date,
              status: "approved",
              data: {
                is_withdraw_payment: false,
                is_fund_transfer: false,
                is_interest: false,
                is_adjustment: false,
                is_for_loan_payments: false,
                accounting_entry_reference_number: @accounting_entry.reference_number,
                beginning_balance: 0.0,
                ending_balance: data[:psa_balance].to_f
              }
              )
           
            acc_trans_mbs.save!
            MemberAccount.find(data[:mbs_account_id]).update(balance: data[:psa_balance].to_f)
        # psa = ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(data[:psa_account_id])).execute!
        # puts "done rehashing Member account #{data[:psa_account_id]}"
        # mbs = ::MemberAccounts::Rehash.new(member_account:MemberAccount.find(data[:mbs_account_id])).execute!
        # puts "done rehashing Member account #{data[:mbs_account_id]}"
      end
      @transfer_savings_record
    end

    def approve_accounting_entry!
      config = {
        accounting_entry_data: @accounting_entry.with_indifferent_access,
        user: @user
      }
      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                        config: config
                      ).execute!

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
