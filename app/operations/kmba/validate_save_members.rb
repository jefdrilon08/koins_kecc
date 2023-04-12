module Kmba
  class ValidateSaveMembers < AppValidator 
    def initialize(config:)
      super()
      @config               = config
      # raise @config.inspect
    end

    def execute!
      #validate the member_data

      if @config.blank?
        @errors[:messages] << {
          key: "no_member", 
          message: "No Member Record Found!"
        }
      else 
        @config.map{ |a|
          if a.blank?
            @errors[:messages] << {
              key: "no_member", 
              message: "No Member Record Found!"
            }
          end

          if a[:first_name].blank?
            @errors[:messages] << {
              key: "first_name", 
              message: "first_name not found"
            }
          end 

          if a[:first_name].nil?
            @errors[:messages] << {
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
              key: "middle_name", 
              message: "middle not found"
            }
          end

          if a[:data][:address][:street].blank?
            @errors[:messages] << {
              key: "address_street", 
              message: "Address Street not found"
            }
          end

          if a[:data][:address][:district].blank?
            @errors[:messages] << {
              key: "address_district",
              message: "Address District not found"
            }
          end

          if a[:data][:address][:city].blank?
            @errors[:messages] << {
              key: "address_city",
              message: "Address City not found"
            }
          end

          if a[:date_of_birth].blank?
            @errors[:messages] << {
              key: "date_of_birth",
              message: "Date of Birth not found"
            }
          end

          if a[:gender].blank?
            @errors[:messages] << {
              key: "gender",
              message: "Gender not found"
            }
          end

          if a[:civil_status].blank?
            @errors[:messages] << {
              key: "civil_status",
              message: "Civil Status not found"
            }
          end

          if a[:branch_id].blank?
            @errors[:messages] << {
              key: "branch_id",
              message: "Branch not Found"
            }
          end

          if a[:center_id].blank?
            @errors[:messages] << {
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