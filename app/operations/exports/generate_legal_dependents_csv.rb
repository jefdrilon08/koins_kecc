module Exports
	class GenerateLegalDependentsCsv
		def initialize(legal_dependents:)
			@legal_dependents = legal_dependents
		end

		def execute!
			CSV.generate do |csv|
                csv << [
                    :first_name, 
                    :middle_name, 
                    :last_name, 
                    :date_of_birth,
                    :educational_attainment,
                    :course,
                    :is_deceased,
                    :is_tpd,
                    :reference_number,
                    :relationship,
                    :member_identification_number,
                    :uuid
                        ]
                                
                @legal_dependents.each do |ld|
                  if ld.member.identification_number.present?
                      csv << [
                        ld.first_name,
                        ld.middle_name,
                        ld.last_name,
                        ld.date_of_birth,
                        ld.data.with_indifferent_access[:educational_attainment],
                        ld.data.with_indifferent_access[:course],
                        ld.data.with_indifferent_access[:is_deceased],
                        ld.data.with_indifferent_access[:is_tpd],
                        nil,
                        ld.relationship,
                        ld.member.identification_number,
                        ld.id
                        ]
                    end
                end
            end
		end
	end
end