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
                            :member_uuid
                        ]

                @member_accounts.each do |ma|
                    if ma.member.identification_number.present?
                        if ma.account_subtype == "Retirement Fund"
                            code = "RF"
                        elsif ma.account_subtype == "Life Insurance Fund"
                            code = "LIF"
                        elsif ma.account_subtype == "Credit Life Insurance Plan"
                            code = "CLIP"
                        elsif ma.account_subtype == "Hospital Income Insurance Plan"
                            code = "HIIP"
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
                        ma.member.id
                        ]
                    end
                end
            end
		end
	end
end