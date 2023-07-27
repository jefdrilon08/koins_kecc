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
          
          center = Center.where(id: member["center_id"])
          branch = Branch.where(id: member["branch_id"])

          if member["center_id"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: member["identification_number"],
              key: "center_id",
              message: "Center not found"
            }
          elsif center.count == 0
            @errors[:messages] << {
              code: "KMBA-004",
              member_id: member["identification_number"],
              key: "center_id",
              message: "Center is not valid"
            }
          end

          if member["branch_id"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: member["identification_number"],
              key: "branch_id",
              message: "Branch not Found"
            }
          elsif branch.count == 0
            @errors[:messages] << {
              code: "KMBA-004",
              member_id: member["identification_number"],
              key: "branch_id",
              message: "Branch is not Valid"
            }
          end

          if member["first_name"].blank?
            @errors[:messages] << {
              code: "KMBA-001", 
              member_id: member["identification_number"],
              key: "first_name", 
              message: "first_name not found"
            }
          end

          # Validate Middle Name
          # if member[:middle_name].blank?
          #   @errors[:messages] << {
          #     key: "middle_name", 
          #     message: "middle not found"
          #   }
          # end 

          if member["last_name"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              last_name_of: member["identification_number"],
              key: "middle_name", 
              message: "Last Name not found"
            }
          end

          if member["gender"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: member["identification_number"],
              key: "gender",
              message: "Gender not found"
            }
          end

          if member["date_of_birth"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: member["identification_number"],
              key: "date_of_birth",
              message: "Date of Birth not found"
            }
          end 

          if member["civil_status"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: member["identification_number"],
              key: "civil_status",
              message: "Civil Status not found"
            }
          end   

          if member["data"]["address"]["street"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: member[:identification_number],
              key: "address_street", 
              message: "Address Street not found"
            }
          end


          # if member[:data][:address][:district].blank?
          #   @errors[:messages] << {
          #     code: "KMBA-001",
          #     member_id: member[:identification_number],
          #     key: "address_district",
          #     message: "Address District not found"
          #   }
          # end

          # if member[:data][:address][:city].blank?
          #   @errors[:messages] << {
          #     code: "KMBA-001",
          #     member_id: member[:identification_number],
          #     key: "address_city",
          #     message: "Address City not found"
          #   }
          # end
        }  
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors 
    end
  end
end