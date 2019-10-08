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
                :uuid,
                :member_uuid
                
                ]
        @beneficiaries.each do |b|
          if b.member.identification_number.present?
              if b.is_primary.nil?
                is_pri = "false"
              else
                is_pri = b.is_primary
              end    

              csv << [
                b.first_name,
                b.middle_name,
                b.last_name,
                is_pri,
                b.date_of_birth,            
                b.relationship,
                nil,
                b.member.identification_number,
                b.id,
                b.member.id
              ]
          end
        end
      end
		end
	end
end