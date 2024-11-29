module Kmba
  class ValidateSavePaymentFromKcoop < AppValidator
    def initialize(payments:)
      super()
      @payments               = payments
    end

    def execute!
      if @payments.nil? || @payments.empty?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "no_payments",
          message: "No Payments Record Found!"
        }
      end

      if @payments["branch_id"].nil? || @payments["branch_id"].empty?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "branch_id",
          message: "No Branch Found!"
        }
      end

      if @payments["user"].nil? || @payments["user"].empty?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "user",
          message: "No User Found!"
        }
      end

      if @payments["api_from"].nil? || @payments["api_from"].empty?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "api_from",
          message: "No API From Found!"
        }
      end

      if @payments["data"].nil? || @payments["data"].empty?
        @errors[:messages] << {
          code: "KMBA-001",
          key: "data",
          message: "No Data Found!"
        }
      end

      @payments["data"].each do |d|
        if d["member_id"].nil? || d["member_id"].empty?
          @errors[:messages] << {
            code: "KMBA-001",
            key: "member_id",
            message: "Member ID not Found!"
          }
        end
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end

    # private

    # def validate_record(record)
    #   if record["member_id"].blank?
    #     @errors[:messages] << {
    #       code: "KMBA-003",
    #       key: "identification_number",
    #       message: "Identification Number Not Found!"
    #     }
    #   else
    #     member = Member.find_by(record["member_id"])
    #     if member.nil?
    #       @errors[:messages] << {
    #         code: "KMBA-004",
    #         key: "identification_number",
    #         message: "Identification Number is not VALID!"
    #       }
    #     end
    #   end

    #   if record["reference_num"].blank?
    #     @errors[:messages] << {
    #       code: "KMBA-003",
    #       key: "reference_num",
    #       message: "Reference Number Not Found!"
    #     }
    #   end

    #   if AccountTransaction.where(external_ref: record["reference_num"]).present?
    #     @errors[:messages] << {
    #       code: "KMBA-004",
    #       key: "identification_number",
    #       message: "Account Transaction is Already Exist"
    #     }
    #   end

    #   if record["lif_amount"].blank?
    #     @errors[:messages] << {
    #       code: "KMBA-003",
    #       key: "lif_amount",
    #       message: "Life Insurance Amount Not Found!"
    #     }
    #   end

    #   if record["rf_amount"].blank?
    #     @errors[:messages] << {
    #       code: "KMBA-003",
    #       key: "rf_amount",
    #       message: "Retirement Fund Amount Not Found!"
    #     }
    #   end
    # end
  end
end
