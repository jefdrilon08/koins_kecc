module Exports
	class GenerateMemberAccountsCsv
		def initialize(member_accounts:)
			@member_accounts = member_accounts
		end

		def execute!
	       CSV.generate do |csv|
                        csv << [ 
                            :uuid,
                            :member_id,
                            :account_type,
                            :account_subtype,
                            :balance,
                            :center_id,
                            :branch_id,   
                            :status,
                            :maintaining_balance,
                            :created_at,
                            :updated_at,
                            :data
                        ]

                @member_accounts.find_in_batches(batch_size: 1000) do |group|
                    group.each do |ma|
                        if ma.status == "active"

                            if ma.data.nil?
                                ma_data = nil
                            else
                                ma_data = ma.data.with_indifferent_access.to_json
                            end

                            csv << [
                                ma.id,
                                ma.member_id,
                                ma.account_type,
                                ma.account_subtype,
                                ma.balance,
                                ma.center_id,
                                ma.branch_id,
                                ma.status,
                                ma.maintaining_balance,
                                ma.created_at,
                                ma.updated_at,
                                ma_data
                            ]
                        end
                    end
                end
            end
		end
	end
end