module Members
  class ImportMembersFromCsvFile
    def initialize(file:)
      @file = file
    end

    def execute!
      load_csv_file!
    end

    private

    def load_csv_file!
      CSV.foreach(@file.path, headers: true) do |row|
        identification_number = row['identification_number']
        member_record = Member.where(identification_number: identification_number).first

        if member_record.nil?
          member = Member.new
          insurance_status = row['insurance_status']

          member.first_name = row['first_name']
          member.middle_name = row['middle_name']
          member.last_name = row['last_name']

          recognition_date = row['recognition_date']
          status = row['status']

          if recognition_date.present? && insurance_status.present?
            if insurance_status == "inforce" || insurance_status == "lapsed" 
              if status == "cleared"
                member.status = "cleared"
                member.insurance_status = "cleared"
              else  
                member.status = "active"
                member.insurance_status = insurance_status
              end
            elsif insurance_status == "dormant"
              if status == "archived"
                member.status = "archived"
                member.insurance_status = insurance_status
              elsif status == "resigned"
                member.status = "resigned"
                member.insurance_status = "resigned"
              else
                member.status = status
                member.insurance_status = insurance_status
              end
            elsif insurance_status == "resigned"
              member.status = "resigned"
              member.insurance_status = insurance_status
            elsif insurance_status == "cleared"
              member.status = "cleared"
              member.insurance_status = insurance_status
            elsif insurance_status == "pending"
              member.status = "pending"
              member.insurance_status = insurance_status  
            elsif row['member_type'] == "GK"
              member.status = "resigned"
              member.insurance_status = insurance_status
            end
          elsif recognition_date.nil?
            member.insurance_status = insurance_status
            member.status = "pending"
          end

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
  
          member.place_of_birth = row['place_of_birth']
          member.mobile_number = row['cellphone_number']
          member.gender = row['gender']
          member.civil_status = row['civil_status']
          member.date_resigned = row['date_resigned']
          
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
          cluster = Cluster.first
          if branch.nil?
            branch =  Branch.new
            branch.name = row['branch']
            name_branch = row['branch']
            branch.short_name = name_branch[0..3].upcase
            branch.cluster_id = cluster.id
            branch.member_counter = 0
            branch.save!
            member.branch = branch
          else
            member.branch = branch
          end 

          center_name = row['center'].upcase
          center = Center.where(name: center_name, branch_id: branch.id).first
          if center.nil?
            center = Center.new
            center.name = row['center'].upcase
            center.short_name = row['center'].upcase
            center.meeting_day = 1
            center.branch = branch
            center.save!
            member.center = center
          else
            member.center = center
          end

          member.identification_number = ::Members::GenerateMemberIdentificationNumber.new(
                                                member: member
                                                ).execute!
          
          member.save!
          member.branch.update(member_counter: member.branch.member_counter + 1)
          Members::GenerateMissingAccounts.new(
                          config: { member: member } 
                    ).execute!
        else
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

          insurance_status = row['insurance_status']

          if row['recognition_date'].present? && insurance_status.present?  
            if insurance_status == "inforce" || insurance_status == "lapsed"
              if row['status'] == "cleared"
                status = "cleared"
                insurance_status = "cleared"
              else
                status = "active"
              end
            elsif insurance_status == "dormant"
              if row['status'] == "archived"
                status = "archived"
              elsif row['status'] == "resigned"
                status = "resigned"
                insurance_status = "resigned"
              else
                status = row['status']
                insurance_status = "dormant"
              end
            elsif insurance_status == "pending"
              status = "pending"
            elsif insurance_status == "resigned"
              status = "resigned"
            elsif row['member_type'] == "GK"
              status = "resigned"
            elsif row['status'] == "archived"
              status = "archived"
            elsif row['status'] == "cleared"
              status = "cleared"
              insurance_status = "cleared"
            end
          else
            status = "pending"
          end
            
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
            member_data[:government_identification_numbers][:sss_number] = sss_number
            member_data[:government_identification_numbers][:tin_number] = tin_number
            member_data[:government_identification_numbers][:pag_ibig_number] = pag_ibig_number
            member_data[:government_identification_numbers][:phil_health_number] = phil_health_number
  
          member_record.update!(
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
            data: member_data
            )
        end       
      end
    end
  end
end
