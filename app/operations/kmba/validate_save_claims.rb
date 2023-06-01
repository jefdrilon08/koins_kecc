module Kmba
  class ValidateSaveClaims < AppValidator 
    def initialize(claims:)
      super()
      @claims               = claims
      # raise @claims.inspect
    end
 
    def execute!
      if @claims.nil?
        @errors[:messages] << {
          key: "no_claims", 
          message: "No Claims Record Found!"
        }
      else 
        @claims.map{ |a|

          center = Center.where(id: a[:center_id])
          branch = Branch.where(id: a[:branch_id])

          if a[:date_prepared].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "date_prepared", 
              message: "Date Prepared not found"
            }
          end

          if a[:prepared_by].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "prepared_by", 
              message: "Prepared By not found"
            }
          end

          if a[:created_at].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "created_at", 
              message: "Created at By not found"
            }
          end

          if a[:updated_at].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "updated_at", 
              message: "Updated at at By not found"
            }
          end

          if a[:member_id].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "member_id", 
              message: "Member ID By not found"
            }
          end

          if a[:center_id].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "center_id", 
              message: "Center ID not found"
            }
          elsif center.count == 0
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "center_id", 
              message: "Center ID is not VALID" 
            }  
          end

          if a[:branch_id].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "branch_id", 
              message: "Branch ID not found"
            }
          elsif branch.count == 0 
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "branch_id", 
              message: "Branch ID is NOT VALID"
            }
          end

          if a[:claim_type] == 'CLIP' or a[:claim_type] == 'K-BENTE' or a[:claim_type] == 'KUYA JUN SCHOLARSHIP PROGRAM' 
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
              key: "claim_type", 
              message: "Claim type is not BLIP OR HIIP"
            }
          end

          if a[:status] == 'for-approval' or a[:status] == 'pending' or a[:status] == 'for-posting'
            @errors[:messages] << {
              code: "KMBA-001",
              member_id: a[:member_id],
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