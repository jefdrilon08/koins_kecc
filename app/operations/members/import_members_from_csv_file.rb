module Members
  class ImportMembersFromCsvFile
    def initialize(file:, user:)
      @file = file
      @user = user
    end

    def execute!
      load_csv_file!
    end

    private

    def load_csv_file!
      CSV.foreach(@file.path, headers: true) do |row|
        identification_number = row['identification_number']
        uuid = row['uuid']

        member_record = Member.where(id: uuid).first
        
        # For new record
        if member_record.nil?
          if uuid.nil?
            member = Member.new
            
            recognition_date = row['recognition_date']

            member.status = row['status'] || "pending"
            member.insurance_status = row['insurance_status'] || "pending"

            branch_name = row['branch']
            branch = Branch.where(name: branch_name).first

            if branch.nil?
              cluster = Cluster.first
              
              branch =  Branch.new
              branch.id = row['branch_id']
              branch.name = row['branch']
              name_branch = row['branch']
              branch.short_name = name_branch[0..3].try(:upcase)
              branch.cluster_id = cluster.id
              branch.member_counter = 0
              branch.save!
              member.branch = branch
            else
              member.branch = branch
            end 

            center_name = row['center'].try(:upcase)
            center_id = row['center_id']
            center = Center.where(id: center_id, branch_id: branch.id).first
            
            if center.nil?
              c = Center.where("upper(name) = ? AND branch_id = ?", center_name, branch.id).first

              if c.nil?
                center = Center.new
              
                if !center_id.nil?
                  center.id = center_id                
                end

                center.name = row['center'].try(:upcase)
                center.short_name = row['center'].try(:upcase)
                center.meeting_day = 1
                center.user = @user
                center.branch = branch
                center.save!
                member.center = center
              else
                member.center = c
              end
            else
              center.update!(name: row['center'].try(:upcase))
              member.center = center
            end

            member.member_type = row['member_type'] || "Regular"

            member.first_name = row['first_name']
            member.middle_name = row['middle_name']
            member.last_name = row['last_name']

            member.date_of_birth = row['date_of_birth'] || Date.today.to_s

            insurance_date_resigned_data = row['insurance_date_resigned_data'] || nil
            
            insurance_resignation_reason_data = row['insurance_resignation_reason_data'] || nil
    
            member.place_of_birth = row['place_of_birth']
            member.home_number = row['home_number']
            member.mobile_number = row['cellphone_number']
            member.gender = row['gender']
            member.civil_status = row['civil_status']
            member.date_resigned = row['date_resigned']
            member.insurance_date_resigned = row['insurance_date_resigned']
            
            member.data = { 
                            address: 
                              { 
                                street: row['address_street'] || "N/A",
                                district: row['address_barangay'] || "N/A",
                                city: row['address_city'] || "N/A",
                                province: row['address_province'] || "N/A",
                                region: row['region'] || "N/A",
                                old_district: row['address_old_district'] || "N/A",
                                old_city: row['address_old_city'] || "N/A"
                              },
                            spouse: 
                              { 
                                first_name: "",
                                last_name: "",
                                middle_name: "",
                                date_of_birth: ""
                              },  
                            num_children_elementary: 0,
                            num_children_high_school: 0,
                            num_children_college: 0,
                            num_children: 0,
                            reason_for_joining: "",
                            recognition_date: recognition_date,
                            resignation: 
                              { 
                                type: nil,
                                code: nil,
                                reason: nil,
                                accounting_reference_number: nil
                              },
                            government_identification_numbers:
                              {
                                tin_number: "",
                                pag_ibig_number: "",
                                sss_number: "",
                                phil_health_number: ""
                              },
                            housing: 
                              {
                                type: "",
                                num_months: 0,
                                num_years: 0,
                                proof: ""
                              },
                            banks: [],
                            legal_dependents: [],
                            beneficiaries: [],
                          }
          

            if identification_number.present?
              member.identification_number = identification_number
            else
              member.identification_number = ::Members::GenerateMemberIdentificationNumber.new(
                                                  member: member
                                                  ).execute!
            end

            member.save!
            
            c = member.branch.try(:member_counter) || 0
            member.branch.update(member_counter: c + 1)
            Members::GenerateMissingAccounts.new(
                            config: { member: member } 
                      ).execute!
          else
          # for existing sa kcoop pero wala sa kmba na mga bago
            member = Member.new

            if !row['uuid'].nil?
              member.id = row['uuid']
            end
 
            branch = Branch.find(row['branch_id'])
            member.branch = branch

            center = Center.where(id: row['center_id']).first

            if center.nil?
                center = Center.new
              
                if !row['center_id'].nil?
                  center.id = row['center_id']               
                end

                center.name = row['center'].try(:upcase)
                center.short_name = row['center'].try(:upcase)
                center.meeting_day = 1
                center.user = @user
                center.branch = branch
                center.save!
                member.center = center
            else 
              member.center = center
            end


            if row['meta_data'].present?
              meta_data = JSON.parse(row['meta_data'])
            else
              meta_data = nil 
            end

            member_data = JSON.parse(row['data'])

            member.first_name = row['first_name']
            member.middle_name = row['middle_name']
            member.last_name =  row['last_name']
            member.gender = row['gender']
            member.date_of_birth = row['date_of_birth']
            member.civil_status = row['civil_status']
            member.home_number = row['home_number']
            member.mobile_number = row['mobile_number']
            member.processed_by = row['processed_by']
            member.approved_by = row['approved_by']
            member.identification_number = identification_number
            member.place_of_birth = row['place_of_birth']
            member.status = row['status']
            member.member_type = row['member_type']
            member.religion = row['religion']
            member.insurance_status = row['insurance_status']
            member.data = member_data
            member.date_resigned = row['date_resigned']
            member.meta = meta_data
            member.created_at = row['created_at']
            member.updated_at = row['updated_at']
            member.access_token = row['access_token']
            member.signature_data = row['signature_data']
            member.modifiable = row['modifiable']
            member.previous_date_resigned = row['previous_date_resigned']
            member.insurance_date_resigned = row['insurance_date_resigned']
            member.member_id = row['member_id']
            member.encrypted_password = row['encrypted_password']
            member.username = row['username']
            member.online_application_id = row['online_application_id']

            member.save!
          end
        else
        # existing record particular to kcoop
          if !["cleared", "transferred", "for-transfer"].include?(row['status'])
            branch_id = row['branch_id']
            branch = Branch.find(branch_id)

            center_id = row['center_id']
            center = Center.where(id: center_id).first

            if row['meta_data'].present?
              meta_data = JSON.parse(row['meta_data'])
            else
              meta_data = nil 
            end

            member_data = JSON.parse(row['data'])
    
            member_record.update!(
              center: center,
              branch: branch,
              first_name: row['first_name'],
              middle_name: row['middle_name'],
              last_name: row['last_name'],
              gender: row['gender'],
              date_of_birth: row['date_of_birth'],
              civil_status: row['civil_status'],
              home_number: row['home_number'],
              mobile_number: row['mobile_number'],
              processed_by: row['processed_by'],
              approved_by: row['approved_by'],
              identification_number: identification_number,
              place_of_birth: row['place_of_birth'],
              status: row['status'],
              member_type: row['member_type'],
              religion: row['religion'],
              insurance_status: row['insurance_status'],
              data: member_data,
              date_resigned: row['date_resigned'],
              meta: meta_data,
              created_at: row['created_at'],
              updated_at: row['updated_at'],
              access_token: row['access_token'],
              signature_data: row['signature_data'],
              modifiable: row['modifiable'],
              previous_date_resigned: row['previous_date_resigned'],
              insurance_date_resigned: row['insurance_date_resigned'],
              member_id: row['member_id'],
              encrypted_password: row['encrypted_password'],
              username: row['username'],
              online_application_id: row['online_application_id']
              )
          end
        end       
      end
    end
  end
end
