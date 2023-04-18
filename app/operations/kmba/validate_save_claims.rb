module Kmba
  class ValidateSaveClaims < AppValidator 
    def initialize(config:)
      super()
      @config               = config
      # raise @config.inspect
    end

    def execute!
      if @config.blank?
        @errors[:messages] << {
          key: "no_member", 
          message: "No Member Record Found!"
        }
      elsif @config.nil?
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

          if a.nil?
            @errors[:messages] << {
              key: "no_member", 
              message: "No Member Record Found!"
            }
          end

          if a[:date_prepared].blank?
            @errors[:messages] << {
              member_id: a[:member_id],
              key: "date_prepared", 
              message: "Date Prepared not found"
            }
          end

          if a[:prepared_by].blank?
            @errors[:messages] << {
              id: a[:prepared_by],
              key: "prepared_by", 
              message: "Prepared By not found"
            }
          end

          if a[:data][:type_of_insurance_policy].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "Insurance Policy is Blank", 
              message: "Insurance Policy must be BLIP OR HIIP"
            }
          end

          if a[:data][:name_of_insured].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "name_of_insured", 
              message: "Name of Insured is not found"
            }
          end

          if a[:data][:beneficiary].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "beneficiary", 
              message: "Name of Beneficiary is not found"
            }
          end

          if a[:data][:classification_of_insured].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "classification_of_insured", 
              message: "Classification of Insured is not found"
            }
          end

          if a[:data][:face_amount].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "face_amount", 
              message: "Face Amount is not found"
            }
          end

          # Arrears are now named Lapsed Amount
          if a[:data][:arrears].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "arrears", 
              message: "Arrears is not found"
            }
          end

          if a[:data][:cause_of_death_tpd_accident].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "cause_of_death_tpd_accident", 
              message: "Cause of Death tpd Accident is not found"
            }
          end

          if a[:data][:length_of_stay].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "length_of_stay", 
              message: "Length of Stay is not found"
            }
          end

          if a[:data][:returned_contribution].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "returned_contribution", 
              message: "Returned Contribution is not found"
            }
          end

          if a[:data][:category_of_cause_of_death_tpd_accident].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "category_of_cause_of_death_tpd_accident", 
              message: "Category of Cause of Death tpd Accident is not found"
            }
          end

          if a[:data][:category_of_cause_of_death_tpd_accident].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "category_of_cause_of_death_tpd_accident", 
              message: "Category of Cause of Death tpd Accident is not found"
            }
          end

          if a[:data][:category_of_cause_of_death_tpd_accident].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "category_of_cause_of_death_tpd_accident", 
              message: "Category of Cause of Death tpd Accident is not found"
            }
          end

          if a[:data][:date_reported].blank?
            @errors[:messages] << {
              id: a[:member_id],
              key: "date_reported", 
              message: ":Date Reported is not found"
            }
          end

          if a[:claim_type] == 'CLIP' or a[:claim_type] == 'K-BENTE' or a[:claim_type] == 'KUYA JUN SCHOLARSHIP PROGRAM' 
            @errors[:messages] << {
              id: a[:member_id],
              key: "claim_type", 
              message: "Claim type is not BLIP OR HIIP"
            }
          end

          if a[:status] == 'for-approval' or a[:status] == 'pending' or a[:status] == 'for-posting'
            @errors[:messages] << {
              id: a[:member_id],
              key: "status", 
              message: "Status is not Approved"
            }
          end   

            
          # validate created_at and updated_ata
          # member_id : uuid microsite         
        }
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors  
    end
  end
end