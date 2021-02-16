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

        if member_record.nil?
          member = Member.new

          if !row['uuid'].nil?
            member.id = row['uuid']
          end

          insurance_status = row['insurance_status']

          member.first_name = row['first_name']
          member.middle_name = row['middle_name']
          member.last_name = row['last_name']

          recognition_date = row['recognition_date']
          status = row['status']
          member.status = status
          member.insurance_status = insurance_status

          # if recognition_date.present? && insurance_status.present?
          #   if insurance_status == "inforce" || insurance_status == "lapsed" 
          #     if status == "cleared"
          #       member.status = "cleared"
          #       member.insurance_status = "cleared"
          #     elsif status == "resigned"
          #       member.status = "resigned"
          #       member.insurance_status = resigned
          #     else  
          #       member.status = "active"
          #       member.insurance_status = insurance_status
          #     end
          #   elsif insurance_status == "dormant"
          #     if status == "archived"
          #       member.status = "archived"
          #       member.insurance_status = insurance_status
          #     elsif status == "resigned"
          #       member.status = "resigned"
          #       member.insurance_status = "resigned"
          #     else
          #       member.status = status
          #       member.insurance_status = insurance_status
          #     end
          #   elsif insurance_status == "resigned"
          #     member.status = "resigned"
          #     member.insurance_status = insurance_status
          #   elsif insurance_status == "cleared"
          #     member.status = "cleared"
          #     member.insurance_status = insurance_status
          #   elsif insurance_status == "pending"
          #     member.status = "pending"
          #     member.insurance_status = insurance_status  
          #   elsif row['member_type'] == "GK"
          #     member.status = "resigned"
          #     member.insurance_status = insurance_status
          #   end
          # elsif recognition_date.nil?
          #   member.insurance_status = insurance_status
            
          #   if status == "archived"
          #     member.status = "archived"
          #   elsif status == "resigned"
          #     member.status = "resigned"
          #   else
          #     member.status = "pending"
          #   end
          # end

          birthday = row['date_of_birth']
          if birthday.nil?
            member.date_of_birth = Date.today.to_s
          else
            member.date_of_birth = row['date_of_birth']
          end

          sss_num = row['sss_number']
          if sss_num.nil?
            sss_num = ""
          end

          phil_health_num = row['phil_health_number']
          if phil_health_num.nil?
            phil_health_num = ""
          end

          pag_ibig_num = row['pag_ibig_number']
          if pag_ibig_num.nil?
            pag_ibig_num = ""
          end

          tin_num = row['tin_number']
          if tin_num.nil?
            tin_num = ""
          end

          if row['insurance_date_resigned_data'].present?
            insurance_date_resigned_data = row['insurance_date_resigned_data']
          else
            insurance_date_resigned_data = nil
          end

          if row['insurance_resignation_reason_data'].present?
            insurance_resignation_reason_data = row['insurance_resignation_reason_data']
          else
            insurance_resignation_reason_data = nil
          end
  
          member.place_of_birth = row['place_of_birth']
          member.mobile_number = row['cellphone_number']
          member.gender = row['gender']
          member.civil_status = row['civil_status']
          member.date_resigned = row['date_resigned']
          member.insurance_date_resigned = row['insurance_date_resigned']
          
          member.data = { 
                          address: 
                            { 
                              street: row['address_street'],
                              district: row['address_barangay'],
                              city: row['address_city']
                            },
                          spouse: 
                            { 
                              first_name: row['spouse_first_name'],
                              last_name: row['spouse_last_name'],
                              middle_name: row['spouse_middle_name'],
                              date_of_birth: row['spouse_date_of_birth']
                            },  
                          num_children: row['number_of_children'],
                          recognition_date: recognition_date,
                          resignation: 
                            { 
                              type: row['resignation_type'],
                              code: row['resignation_code'],
                              reason: row['resignation_reason'],
                              accounting_reference_number: ''
                            },
                            insurance_resignation: 
                            { 
                              date_resigned: insurance_date_resigned_data,
                              resignation_reason: insurance_resignation_reason_data,
                            },
                          government_identification_numbers:
                            {
                              tin_number: tin_num,
                              pag_ibig_number: pag_ibig_num,
                              sss_number: sss_num,
                              phil_health_number: phil_health_num
                            },
                          num_children_elementary: 0,
                          num_children_high_school: 0,
                          num_children_college: 0,
                          reason_for_joining: "",
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
          
          member_type = row['member_type']
          if member_type.nil?
            member.member_type = "Regular"
          else
            member.member_type = member_type
          end

          branch_name = row['branch']
          branch = Branch.where(name: branch_name).first

          if branch.nil?
            if identification_number.present?
              cluster = Cluster.where(short_name: identification_number[0..1]).first
            else
              cluster = Cluster.first
            end

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
            center = Center.new
            center.name = row['center'].try(:upcase)
            center.short_name = row['center'].try(:upcase)
            center.meeting_day = 1
            center.user = @user
            center.branch = branch
            center.save!
            member.center = center
          else
            center.update!(name: row['center'].try(:upcase))
            member.center = center
          end

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
          if !["cleared", "transferred", "for-transfer"].include?(row['status'])
            branch_name = row['branch']
            branch = Branch.where(name: branch_name).first

            center_name = row['center'].try(:upcase)
            center_id = row['center_id']
            center = Center.where(id: center_id).first
            
            if center.nil?
              center = Center.new
              center.name = row['center'].try(:upcase)
              center.short_name = row['center'].try(:upcase)
              center.meeting_day = 1
              center.user = @user
              center.branch = branch
              center.save!
            else
              center.update!(name: row['center'].try(:upcase), user: @user)
            end

            member_data = member_record.data.with_indifferent_access

            sss_num = row['sss_number']
            if sss_num.nil?
              sss_number = ''
            else
              sss_number = sss_num
            end

            phil_health_num = row['phil_health_number']
            if phil_health_num.nil?
              phil_health_number = ''
            else
              phil_health_number = phil_health_num
            end

            pag_ibig_num = row['pag_ibig_number']
            if pag_ibig_num.nil?
              pag_ibig_number = ''
            else
              pag_ibig_number = pag_ibig_num
            end

            tin_num = row['tin_number']
            if tin_num.nil?
              tin_number = ''
            else
              tin_number = tin_num
            end

            if row['insurance_date_resigned_data'].present?
              insurance_date_resigned_data = row['insurance_date_resigned_data']
            else
              insurance_date_resigned_data = nil
            end

            if row['insurance_resignation_reason_data'].present?
              insurance_resignation_reason_data = row['insurance_resignation_reason_data']
            else
              insurance_resignation_reason_data = nil
            end

            insurance_status = row['insurance_status']
            status = row['status']

            # if row['recognition_date'].present? && insurance_status.present?  
            #   if insurance_status == "inforce" || insurance_status == "lapsed"
            #     if row['status'] == "cleared"
            #       status = "cleared"
            #       insurance_status = "cleared"
            #     else
            #       status = "active"
            #     end
            #   elsif insurance_status == "dormant"
            #     if row['status'] == "archived"
            #       status = "archived"
            #     elsif row['status'] == "resigned"
            #       status = "resigned"
            #       insurance_status = "resigned"
            #     else
            #       status = row['status']
            #       insurance_status = "dormant"
            #     end
            #   elsif insurance_status == "pending"
            #     status = "pending"
            #   elsif insurance_status == "resigned"
            #     status = "resigned"
            #   elsif row['member_type'] == "GK"
            #     status = "resigned"
            #   elsif row['status'] == "archived"
            #     status = "archived"
            #   elsif row['status'] == "cleared"
            #     status = "cleared"
            #     insurance_status = "cleared"
            #   end
            # else
            #   status = "pending"
            # end
              
              member_data[:recognition_date] = row['recognition_date']
              member_data[:address][:street] = row['address_street']
              member_data[:address][:district] = row['address_barangay']
              member_data[:address][:city] = row['address_city']
              member_data[:num_children] = row['number_of_children']
              member_data[:spouse][:first_name] = row['spouse_first_name']
              member_data[:spouse][:last_name] = row['spouse_last_name']
              member_data[:spouse][:middle_name] = row['spouse_middle_name']
              member_data[:spouse][:date_of_birth] = row['spouse_date_of_birth']
              member_data[:resignation][:type] = row['resignation_type']
              member_data[:resignation][:code] = row['resignation_code']
              member_data[:resignation][:reason] = row['resignation_reason']
              member_data[:insurance_resignation][:code] = row['resignation_code']
              member_data[:insurance_resignation][:reason] = row['resignation_reason']
              member_data[:government_identification_numbers][:sss_number] = sss_number
              member_data[:government_identification_numbers][:tin_number] = tin_number
              member_data[:government_identification_numbers][:pag_ibig_number] = pag_ibig_number
              member_data[:government_identification_numbers][:phil_health_number] = phil_health_number
    
            member_record.update!(
              identification_number: identification_number,
              center: center,
              branch: branch,
              member_type: row['member_type'],
              status: status,
              insurance_status: insurance_status,
              first_name: row['first_name'],
              middle_name: row['middle_name'],
              last_name: row['last_name'],
              date_of_birth: row['date_of_birth'],
              gender: row['gender'],
              civil_status: row['civil_status'],
              place_of_birth: row['place_of_birth'],
              mobile_number: row['cellphone_number'],
              date_resigned: row['date_resigned'],
              insurance_date_resigned: row['insurance_date_resigned'],
              data: member_data
              )
          end
        end       
      end
    end
  end
end
