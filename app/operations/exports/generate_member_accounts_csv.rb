module Exports
	class GenerateMemberAccountsCsv
		def initialize(member_accounts:)
			@member_accounts = member_accounts
		end

		def execute!
	       CSV.generate do |csv|
                        csv << [ 
                            :insurance_type,
                            :balance,
                            :member_id,
                            :account_number,
                            :status,
                            :branch,   
                            :center,
                            :uuid,
                            :member_uuid,
                            :equity_value,
                        ]

                @member_accounts.find_in_batches(batch_size: 1000) do |group|
                    group.each do |ma|
                        if ma.member.identification_number.present?
                            if ma.account_subtype == "Retirement Fund"
                                code = "RF"
                            elsif ma.account_subtype == "Life Insurance Fund"
                                code = "LIF"
                            elsif ma.account_subtype == "Credit Life Insurance Plan"
                                code = "CLIP"
                            elsif ma.account_subtype == "Hospital Income Insurance Plan"
                                code = "HIIP"
                            elsif ma.account_subtype == "Policy Loan"
                                code = "PL"
                            end

                            if ma.data.nil?
                                ev = nil
                            else
                                ev = ma.data.with_indifferent_access[:equity_value]
                            end

                            csv << [
                            code,
                            ma.balance,
                            ma.member.identification_number,
                            nil,
                            ma.status,
                            ma.branch,
                            ma.center,
                            ma.id,
                            ma.member.id,
                            ev
                            ]
                        end
                    end
                end
            end
		end
	end
end