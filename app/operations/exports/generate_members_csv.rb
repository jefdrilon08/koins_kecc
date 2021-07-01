module Exports
	class GenerateMembersCsv
		def initialize(members:)
			@members = members
		end

		def execute!
	       CSV.generate do |csv|
                        csv << [ 
                            :uuid,
                            :center_id,
                            :branch_id,
                            :first_name,
                            :middle_name,
                            :last_name,
                            :gender,
                            :date_of_birth,
                            :civil_status,
                            :home_number,
                            :mobile_number,
                            :processed_by,
                            :approved_by,
                            :identification_number,
                            :place_of_birth,
                            :status,
                            :member_type,
                            :religion,    
                            :insurance_status,
                            :data,
                            :date_resigned,
                            :meta_data,
                            :created_at,
                            :updated_at,
                            :access_token,
                            :signature_data,
                            :modifiable,
                            :previous_date_resigned,
                            :insurance_date_resigned,
                            :member_id,
                            :encrypted_password,
                            :username,
                            :online_application_id,
                            :center,
                            :branch,
                            :recognition_date,
                            :lapse,
                            # m.lif_amount,
                            # m.rf_amount
                            
                        ]
                @members.find_in_batches(batch_size: 1000) do |group|
                    group.each do |m|
                        if m.identification_number.present?
                
                            recognition_date = m.data.with_indifferent_access[:recognition_date]
                            if recognition_date.nil?
                                recognition_date = nil
                                lapse = nil
                            else
                                lapse = m.life_number_of_lapsed
                            end
                
                            if m.meta.present?
                                meta_data = m.meta.with_indifferent_access.to_json
                            else
                                meta_data = nil
                            end

                            csv << [
                                m.id,
                                m.center.id,
                                m.branch.id,
                                m.first_name,
                                m.middle_name,
                                m.last_name,
                                m.gender,
                                m.date_of_birth,
                                m.civil_status,
                                m.home_number,
                                m.mobile_number,
                                m.processed_by,
                                m.approved_by,
                                m.identification_number,
                                m.place_of_birth,
                                m.status,
                                m.member_type,
                                m.religion,    
                                m.insurance_status,
                                m.data.with_indifferent_access.to_json,
                                m.date_resigned,
                                meta_data,
                                m.created_at,
                                m.updated_at,
                                m.access_token,
                                m.signature_data,
                                m.modifiable,
                                m.previous_date_resigned,
                                m.insurance_date_resigned,
                                m.member_id,
                                m.encrypted_password,
                                m.username,
                                m.online_application_id,
                                m.center,
                                m.branch,
                                recognition_date,
                                lapse,
                                # m.lif_amount,
                                # m.rf_amount
                            ]
                        end
                    end
                end
            end
		end
	end
end