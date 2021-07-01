module Exports
	class GenerateAccountTransactionsCsv
    attr_accessor :account_transactions

		def initialize(account_transactions:)
			@account_transactions = account_transactions
		end

		def execute!
	       CSV.generate do |csv|
                        csv << [ 
                            :id,
                            :subsidiary_id,
                            :subsidiary_type,
                            :amount,
                            :transaction_type,
                            :transacted_at,
                            :status,
                            :data,
                            :created_at,
                            :updated_at
                        ]

                @account_transactions.find_in_batches(batch_size: 1000) do |group|
                    group.each do |at|
                        member_account = MemberAccount.where(id: at.subsidiary_id)

                        at_data = at.data.with_indifferent_access.to_json

                        if member_account.present?
                            csv << [
                            at.id,
                            at.subsidiary_id,
                            at.subsidiary_type,
                            at.amount,
                            at.transaction_type,
                            at.transacted_at.strftime("%Y-%m-%d"),
                            at.status,
                            at_data,
                            at.created_at,
                            at.updated_at
                            ]
                        end
                    end
                end
            end
		end
	end
end
