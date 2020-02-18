module Exports
	class GenerateAccountTransactionsCsv
		def initialize(account_transactions:)
			@account_transactions = account_transactions
		end

		def execute!
	       CSV.generate do |csv|
                        csv << [ 
                            :insurance_account_uuid,
                            :amount,
                            :transaction_type,
                            :transacted_at,
                            :particular,
                            :status,
                            :transacted_by,
                            :approved_by,
                            :voucher_reference_number,
                            :transaction_number,
                            :bank_id,
                            :accounting_code_id,
                            :uuid,
                            :beginning_balance,
                            :ending_balance,
                            :transaction_date,
                            :is_adjustment,
                            :is_for_loan_payments,
                            :is_for_exit_age,
                            :is_withdraw_payment,
                            :is_fund_transfer,
                            :is_interest
                        ]

                @account_transactions.each do |at|
                    member_account = MemberAccount.where(id: at.subsidiary_id)
                    if member_account
                        csv << [
                        member_account.ids.first,
                        at.amount,
                        at.transaction_type,
                        at.transacted_at.strftime("%Y-%m-%d"),
                        at.data.with_indifferent_access[:accounting_entry_particular],
                        at.status,
                        nil,
                        nil,
                        at.data.with_indifferent_access[:accounting_entry_reference_number],
                        nil,
                        nil,
                        nil,
                        at.id,
                        at.data.with_indifferent_access[:beginning_balance],
                        at.data.with_indifferent_access[:ending_balance],
                        at.transacted_at.strftime("%Y-%m-%d"),
                        at.data.with_indifferent_access[:is_adjustment],
                        at.data.with_indifferent_access[:is_for_loan_payments],
                        at.data.with_indifferent_access[:is_for_exit_age],
                        at.data.with_indifferent_access[:is_withdraw_payment],
                        at.data.with_indifferent_access[:is_fund_transfer],
                        at.data.with_indifferent_access[:is_interest]
                        ]
                    end
                end
            end
		end
	end
end