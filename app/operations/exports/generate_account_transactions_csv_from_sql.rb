module Exports
	class GenerateAccountTransactionsCsvFromSql
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

                @account_transactions.each do |at|
                    member_account = MemberAccount.where(id: at.fetch("subsidiary_id")).first

                    at_data = JSON.parse(at.fetch("at_data")).to_json

                    if member_account.present?
                        csv << [
                        at.fetch("at_id"),
                        at.fetch("subsidiary_id"),
                        at.fetch("subsidiary_type"),
                        at.fetch("amount"),
                        at.fetch("transaction_type"),
                        at.fetch("transacted_at").strftime("%Y-%m-%d"),
                        at.fetch("status"),
                        at_data,
                        at.fetch("created_at"),
                        at.fetch("updated_at")
                        ]
                    end
                end
            end
		end
	end
end
