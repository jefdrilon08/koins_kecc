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
          
          center        = Center.where(id: member["center_id"])
          branch        = Branch.where(id: member["branch_id"])
          external_ref  = Member.where(external_ref: member["external_ref"]).count


          if member["center_id"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["external_ref"],
              key: "center_id",
              message: "Center not found"
            }
          elsif center.count == 0
            @errors[:messages] << {
              code: "KMBA-004",
              external_ref: member["external_ref"],
              key: "center_id",
              message: "Center is not valid"
            }
          end

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

          if member["first_name"].blank?
            @errors[:messages] << {
              code: "KMBA-001", 
              external_ref: member["external_ref"],
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
              last_name_of: member["external_ref"],
              key: "middle_name", 
              message: "Last Name not found"
            }
          end

          if member["gender"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["external_ref"],
              key: "gender",
              message: "Gender not found"
            }
          end

          if member["date_of_birth"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["external_ref"],
              key: "date_of_birth",
              message: "Date of Birth not found"
            }
          end 

          if member["civil_status"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["external_ref"],
              key: "civil_status",
              message: "Civil Status not found"
            }
          end

          if member["mobile_number"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["external_ref"],
              key: "mobile_number",
              message: "Mobile_number not found"
            }
          end

          if member["insurance_status"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member["external_ref"],
              key: "insurance_status",
              message: "Insurance Status not found"
            }
          end      

          if member["data"]["address"]["street"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member[:external_ref],
              key: "address_street", 
              message: "Address Street not found"
            }
          end

          if member["data"]["address"]["district"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member[:external_ref],
              key: "address_district",
              message: "Address District not found"
            }
          end

          if member["data"]["address"]["city"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              external_ref: member[:external_ref],
              key: "address_city",
              message: "Address City not found"
            }
          end

          if member["insurance_status"] == "pending"
            if member["external_ref"].blank?
              @errors[:messages] << {
                code: "KMBA-001",
                external_ref: member[:external_ref],
                key: "external_ref", 
                message: "ExternalRef not found"
              }
            elsif member["external_ref"] !~ /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/
              @errors[:messages] << {
                code: "KMBA-002",
                external_ref: member["external_ref"],
                key: "external_ref",
                message: "ExternalRef is not a valid UUID"
              }
            elsif external_ref > 0
              @errors[:messages] << {
                code: "KMBA-001",
                external_ref: member["external_ref"],
                key: "external_ref",
                message: "ExternalRef is already exist!"
              }
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