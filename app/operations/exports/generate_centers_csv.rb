module Exports
	class GenerateCentersCsv
		def initialize(centers:)
			@centers = centers
		end

		def execute!
			CSV.generate do |csv|
        csv << [
          :uuid,
          :branch_id, 
          :name, 
          :short_name,
          :created_at,
          :updated_at,
          :meeting_day,
          :user_id
        ]

        @centers.find_in_batches(batch_size: 1000) do |group|
          group.each do |center|
            csv << [
              center.id,
              center.branch_id,
              center.name,
              center.short_name,
              center.created_at,
              center.updated_at,
              center.meeting_day,
              nil,
            ]
          
          end
        end
      end
		end
	end
en