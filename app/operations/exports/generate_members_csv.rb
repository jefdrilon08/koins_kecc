module Exports
	class GenerateMembersCsv
		def initialize(members:)
			@members = members
		end

		def execute!
	       CSV.generate do |csv|
                        csv << [ 
                            :identification_number,
                            :member_type,
                            :status,
                            :insurance_status,
                            :first_name, 
                            :middle_name, 
                            :last_name,
                            :recognition_date,
                            :center, 
                            :branch, 
                            :gender,
                            :date_of_birth,
                            :place_of_birth,
                            :civil_status,
                            :number_of_children,
                            :spouse_first_name,
                            :spouse_last_name,
                            :spouse_middle_name,
                            :spouse_date_of_birth,
                            :address_street,
                            :address_barangay,
                            :address_city,
                            :sss_number,
                            :tin_number,
                            :pag_ibig_number,
                            :phil_health_number,
                            :cellphone_number,
                            :uuid,
                            :meta_id, 
                            :date_resigned,
                            :resignation_type,
                            :resignation_code,
                            :resignation_reason,
                            :insurance_date_resigned,
                            :is_reinstate,
                            :old_previous_mii_member_since,
                            :is_balik_kasapi
                            
                        ]
                @members.each do |m|
                    if m.fetch_government_id("tin_number").present?
                        tin = m.fetch_government_id("tin_number").split("-").join("")
                    elsif m.fetch_government_id("sss_number").present?
                        sss = m.fetch_government_id("sss_number").split("-").join("")
                    elsif m.fetch_government_id("pag_ibig_number").present?
                        pag_ibig = m.fetch_government_id("pag_ibig_number").split("-").join("")
                    elsif m.fetch_government_id("phil_health_number").present?
                        phil_health = m.fetch_government_id("phil_health_number").split("-").join("")
                    end

                    if m.meta
                        meta_id = m.meta
                    else
                        meta_id = ""
                    end

                    date_paid = MembershipPaymentRecord.paid.where("member_id = ? AND membership_name = ?", m.id, "K-MBA").first.try(:date_paid)
                    if !date_paid.nil?
                        recognition_date = date_paid
                    else
                        recognition_date = nil
                    end

                    if !m.data.with_indifferent_access[:resignation].nil?
                        resignation_type = m.data.with_indifferent_access[:resignation][:type]
                        resignation_code = m.data.with_indifferent_access[:resignation][:code]
                        resignation_reason = m.data.with_indifferent_access[:resignation][:reason]
                    else
                        resignation_type = nil
                        resignation_code = nil
                        resignation_reason = nil
                    end

                    csv << [
                    m.identification_number,
                    m.member_type,
                    m.status,
                    m.insurance_status,    
                    m.first_name,
                    m.middle_name,
                    m.last_name,
                    recognition_date,
                    m.center,
                    m.branch,
                    m.gender,
                    m.date_of_birth,
                    m.place_of_birth,
                    m.civil_status,
                    m.data[:number_children],
                    m.data.with_indifferent_access[:spouse][:first_name],
                    m.data.with_indifferent_access[:spouse][:last_name],
                    m.data.with_indifferent_access[:spouse][:middle_name],
                    m.data.with_indifferent_access[:spouse][:date_of_birth],
                    m.data.with_indifferent_access[:address][:street],
                    m.data.with_indifferent_access[:address][:district],
                    m.data.with_indifferent_access[:address][:city],
                    sss,
                    tin,
                    pag_ibig,
                    phil_health,
                    m.mobile_number,
                    m.try(:uuid),
                    meta_id,
                    m.date_resigned,
                    resignation_type,
                    resignation_code,
                    resignation_reason,
                    m.date_resigned,
                    "",
                    "",
                    ""
                    ]
                end
            end
		end
	end
end