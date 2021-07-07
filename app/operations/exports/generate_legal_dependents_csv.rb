module Exports
	class GenerateLegalDependentsCsv
		def initialize(legal_dependents:)
			@legal_dependents = legal_dependents
		end

		def execute!
			CSV.generate do |csv|
        csv << [
          :uuid,
          :first_name, 
          :middle_name, 
          :last_name, 
          :date_of_birth,
          :member_uuid,
          :relationship,
          :data,
          :created_at,
          :updated_at,
          :member_identification_number
        ]

        @legal_dependents.find_in_batches(batch_size: 1000) do |group|
          group.each do |ld|
            if ld.member.identification_number.present?
              csv << [
                ld.id,
                ld.first_name,
                ld.middle_name,
                ld.last_name,
                ld.date_of_birth,
                ld.member.id,
                ld.relationship,
                ld.data.with_indifferent_access.to_json,
                ld.created_at,
                ld.updated_at,
                ld.member.identification_number
              ]
            end
          end
        end
      end
		end
	end
end
