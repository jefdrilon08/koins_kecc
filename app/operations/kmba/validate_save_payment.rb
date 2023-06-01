module Kmba
  class ValidateSavePayment < AppValidator 
    def initialize(payments:)
      super()
      @payments               = payments
      # raise @payments.inspect
    end

    def execute!
      #validate the Payments_data
 
      if @payments.nil?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "no_Payments", 
          message: "No Payments Record Found!"
        }
      else 
        @payments.map{ |a|
          if a[:identification_number].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "identification_number", 
              message: "Identification Number Not Found!"
            }
          end

          if a[:amount].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "amount", 
              message: "Amount Not Found!"
            }
          end

          if a[:account_subtype].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "account_subtype", 
              message: "Account Subtype Not Found!"
            }
          end

          if a[:transacted_at].blank?
            @errors[:messages] << {
              code: "KMBA-001",
              key: "transacted_at", 
              message: "Transacted At Not Found!"
            }
          end

          if a[:status].blank?
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