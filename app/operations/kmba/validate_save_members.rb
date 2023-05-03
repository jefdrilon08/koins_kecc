module Kmba
  class ValidateSaveMembers < AppValidator 
    def initialize(members:)
      super()
      @members               = members
      # raise @members.inspect
    end

    def execute!
     
      if @members.nil?
        @errors[:messages] << {
          code: "KMBA-001",
          message: "No Member Data Record Found!"
        }
      else
        @members.map{ |a|
          # if a.is_a?(Array)
          #   @errors[:messages] << {
          #     code: "KMBA-001",
          #     message: "One Member Data, Record is not Array!"
          #   }
          # end

          if a[:first_name].blank?
            @errors[:messages] << {
              code: "KMBA-001", 
              member_id: a[:identification_number],
              key: "first_name", 
              message: "first_name not found"
            }
          end

          # Validate Middle Name
          # if a[:middle_name].blank?
          #   @errors[:messages] << {
          #     key: "middle_name", 
          #     message: "middle not found"
          #   }
          # end 

          if a[:last_name].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              last_name_of: a[:identification_number],
              key: "middle_name", 
              message: "Last Name not found"
            }
          end 

          if a[:data][:address][:street].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:identification_number],
              key: "address_street", 
              message: "Address Street not found"
            }
          end

          # if a[:data][:address][:district].blank?
          #   @errors[:messages] << {
          #     code: "KMBA-001",
          #     member_id: a[:identification_number],
          #     key: "address_district",
          #     message: "Address District not found"
          #   }
          # end

          # if a[:data][:address][:city].blank?
          #   @errors[:messages] << {
          #     code: "KMBA-001",
          #     member_id: a[:identification_number],
          #     key: "address_city",
          #     message: "Address City not found"
          #   }
          # end

          # if a[:date_of_birth].blank?
          #   @errors[:messages] << {
          #     code: "KMBA-001",
          #     member_id: a[:identification_number],
          #     key: "date_of_birth",
          #     message: "Date of Birth not found"
          #   }
          # end

          if a[:gender].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:identification_number],
              key: "gender",
              message: "Gender not found"
            }
          end

          # if a[:civil_status].blank?
          #   @errors[:messages] << {
          #     code: "KMBA-001",
          #     member_id: a[:identification_number],
          #     key: "civil_status",
          #     message: "Civil Status not found"
          #   }
          # end

          if a[:branch_id].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:identification_number],
              key: "branch_id",
              message: "Branch not Found"
            }
          end

          if a[:center_id].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:identification_number],
              key: "center_id",
              message: "Center not found"
            }
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