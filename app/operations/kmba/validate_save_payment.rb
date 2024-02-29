module Kmba
  class ValidateSavePayment < AppValidator 
    def initialize(payments:)
      super()
      @payments               = payments
    end

    def execute!
      if @payments.nil? || @payments.empty?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "no_Payments", 
          message: "No Payments Record Found!"
        }
      else 
        @payments.map{ |payment|

          member = Member.where(identification_number: payment["identification_number"])
          branch = Branch.where(id: payment["branch_id"])
          
          if payment["data"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "data", 
              message: "Data Not Found!"
            }
          else 
            payment["data"].each do |record|
              validate_record(record)
            end
          end

          if payment["branch_id"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "branch_id", 
              message: "Branch Not Found!"
            }
          elsif branch.count == 0
            @errors[:messages] << {
              code: "KMBA-001",
              key: "branch_id", 
              message: "Branch is NOT VALID!"
            }            
          end 

          if payment["collection_date"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "collection_date", 
              message: "Collection Date Not Found!"
            }   
          end
        }
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors  
    end

    private

    def validate_record(record)
      if record["identification_number"].blank? 
        @errors[:messages] << {
          code: "KMBA-003",
          key: "identification_number", 
          message: "Identification Number Not Found!"
        }
      else
        member = Member.find_by(identification_number: record["identification_number"])
        if member.nil?
          @errors[:messages] << {
            code: "KMBA-004",
            key: "identification_number", 
            message: "Identification Number is not VALID!"
          }
        end
      end

      if record["reference_num"].blank?
        @errors[:messages] << {
          code: "KMBA-003",
          key: "reference_num", 
          message: "Reference Number Not Found!"
        }
      end

      if AccountTransaction.where(external_ref: record["reference_num"]).present?
        @errors[:messages] << {
          code: "KMBA-004",
          key: "identification_number", 
          message: "Account Transaction is Already Exist"
        }
      end

      if record["lif_amount"].blank?
        @errors[:messages] << {
          code: "KMBA-003",
          key: "lif_amount", 
          message: "Life Insurance Amount Not Found!"
        }
      end

      if record["rf_amount"].blank?
        @errors[:messages] << {
          code: "KMBA-003",
          key: "rf_amount", 
          message: "Retirement Fund Amount Not Found!"
        }
      end
    end
  end
end