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
                            :is_adjustment
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
                        "",
                        "",
                        at.data.with_indifferent_access[:accounting_entry_reference_number],
                        "",
                        "",
                        "",
                        at.id,
                        at.data.with_indifferent_access[:beginning_balance],
                        at.data.with_indifferent_access[:ending_balance],
                        at.transacted_at.strftime("%Y-%m-%d"),
                        at.data.with_indifferent_access[:is_adjustment]
                        ]
                    end
                end
            end
		end
	end
end