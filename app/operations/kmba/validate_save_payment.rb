module Kmba
  class ValidateSavePayment < AppValidator 
    def initialize(payments:)
      super()
      @payments               = payments
    end

    def execute!
      if @payments.nil?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "no_Payments", 
          message: "No Payments Record Found!"
        }
      else 
        @payments.map{ |payment|

          member = Member.where(identification_number: payment["identification_number"])

          if payment["identification_number"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "identification_number", 
              message: "Identification Number Not Found!"
            }
          elsif member.count == 0
            @errors[:messages] << {
              code: "KMBA-004",
              key: "identification_number", 
              message: "Identification Number is not VALID!"
            }
          end

          if payment["amount"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "amount", 
              message: "Amount Not Found!"
            }
          end

          if payment["account_subtype"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "account_subtype", 
              message: "Account Subtype Not Found!"
            }
          end

          if payment["transacted_at"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "transacted_at", 
              message: "Transacted At Not Found!"
            }
          end

          if payment["status"].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "status", 
              message: "Status Not Found!"
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