module Kmba
  class ValidateSaveMembers < AppValidator
    def initialize(members:)
      super()
      @members            = members

    end

    def execute!
      if @members.nil?
        @errors[:messages] << {
          code: "KMBA-001",
          message: "No Member Data Record Found!"
        }
      else
        @members.map{ |member|

          branch        = Branch.where(id: member["branch_id"])
          external_ref  = Member.where(external_ref: member["external_ref"]).count

          if member["branch_id"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["external_ref"],
              key: "branch_id",
              message: "Branch not Found"
            }
          elsif branch.count == 0
            @errors[:messages] << {
              code: "KMBA-004",
              external_ref: member["external_ref"],
              key: "branch_id",
              message: "Branch is not Valid"
            }
          end

          if member["receive_date"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["receive_date"],
              key: "receive_date",
              message: "Receive Date not Found"
            }
          end

          if member["api_from"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["api_from"],
              key: "api_from",
              message: "Api From not Found"
            }
          end


          member["data"].each_with_index do |m, index|
            identification_number = Member.where(identification_number: m["identification_number"])

            if m["insurance_status"].blank?
              @errors[:messages] << {
                code: "KMBA-001",
                external_ref: member["insurance_status"],
                key: "insurance_status",
                message: "Insurance Status is blank"
              }
            end

            if m["center_id"].blank?
              @errors[:messages] << {
                code: "KMBA-001",
                external_ref: member["center_id"],
                key: "center_id",
                message: "Center Id is blank"
              }
            end

            if m["insurance_status"] == "pending"
              if m["first_name"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member["external_ref"],
                  key: "first_name",
                  message: "First Name not found"
                }
              end

              if m["last_name"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  last_name_of: member["external_ref"],
                  key: "last_name",
                  message: "Last Name not found"
                }
              end

              if m["gender"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member["external_ref"],
                  key: "gender",
                  message: "Gender not found"
                }
              end

              if m["date_of_birth"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member["external_ref"],
                  key: "date_of_birth",
                  message: "Date of Birth not found"
                }
              end

              if m["civil_status"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member["external_ref"],
                  key: "civil_status",
                  message: "Civil Status not found"
                }
              end

              if m["mobile_number"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member["external_ref"],
                  key: "mobile_number",
                  message: "Mobile Number not found"
                }
              end

              if m["address_street"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member[:external_ref],
                  key: "address_street",
                  message: "Address Street not found"
                }
              end

              if m["address_district"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member[:external_ref],
                  key: "address_district",
                  message: "Address District not found"
                }
              end

              if m["address_city"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member[:external_ref],
                  key: "address_city",
                  message: "Address City not found"
                }
              end

              if m["external_ref"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member[:external_ref],
                  key: "external_ref",
                  message: "External Ref not found"
                }
              end
            end

            if m["insurance_status"] == "inforce" || m["insurance_status"] == "lapsed"
              if m["identification_number"].blank?
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member["external_ref"],
                  key: "first_name",
                  message: "This Member is #{m["insurance_status"]} Identification Number is not found"
                }
              end

              if identification_number.count == 0
                @errors[:messages] << {
                  code: "KMBA-001",
                  external_ref: member["identification_number"],
                  key: "first_name",
                  message: "Identification Number : #{m["identification_number"]} is not found"
                }
              end
            end
          end
        }
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
