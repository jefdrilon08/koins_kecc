module Exports
	class GenerateBeneficiariesCsv
		def initialize(beneficiaries:)
			@beneficiaries = beneficiaries
		end

		def execute!
			CSV.generate do |csv|
        csv << [
                :first_name, 
                :middle_name, 
                :last_name,
                :is_primary,
                :date_of_birth,
                :relationship,
                :reference_number,
                :member_identification_number,
                :uuid
                
                ]
        @beneficiaries.each do |b|
          csv << [
            b.first_name,
            b.middle_name,
            b.last_name,
            b.is_primary,
            b.date_of_birth,            
            b.relationship,
            "",
            b.member.identification_number,
            b.id
          ]
        end
      end
		end
	end
end